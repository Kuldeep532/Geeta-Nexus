"""
Aira — Universal AI Support Backend
=====================================
FastAPI backend for the Aira conversational agent.

Architecture
------------
This backend is intentionally FRAMEWORK-AGNOSTIC:
- It accepts plain JSON requests with a "query" + optional "context" field.
- The knowledge base is a generic Markdown/JSON file — swap it for any
  domain without changing the core logic.
- Deployable FREE on: Render, Hugging Face Spaces, Railway, or Fly.io.

Cost control
------------
- Primary: local keyword/embedding search against the Gita knowledge base (FREE).
- Fallback: Gemini 1.5 Flash (Google free tier — 15 RPM / 1M tokens/day).
- No paid voice API is ever called from this backend.

Environment variables required (never hardcode):
    GEMINI_AI_API_KEY   — Google Gemini API key (optional; free tier)
    ALLOWED_ORIGINS     — Comma-separated CORS origins (default: *)
    SECRET_TOKEN        — Simple bearer token to prevent open abuse (optional)
"""

import os
import json
import re
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, HTTPException, Header, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# ── Optional Gemini import (graceful degradation if not installed) ─────────
try:
    import google.generativeai as genai
    _GEMINI_AVAILABLE = True
except ImportError:
    _GEMINI_AVAILABLE = False

# ── Config ─────────────────────────────────────────────────────────────────
GEMINI_KEY = os.environ.get("GEMINI_AI_API_KEY", "")
ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "*").split(",")
SECRET_TOKEN = os.environ.get("SECRET_TOKEN", "")

if _GEMINI_AVAILABLE and GEMINI_KEY:
    genai.configure(api_key=GEMINI_KEY)

app = FastAPI(
    title="Aira — Gita Nexus AI Support",
    description="Universal, framework-agnostic AI companion backend.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Knowledge base ──────────────────────────────────────────────────────────
_KB_PATH = Path(__file__).parent / "knowledge_base.json"
_kb: dict[str, str] = {}


def _load_kb() -> None:
    global _kb
    if _KB_PATH.exists():
        with open(_KB_PATH, encoding="utf-8") as f:
            data = json.load(f)
        # Accept both flat {"q": "a"} and list [{"question": …, "answer": …}]
        if isinstance(data, dict):
            _kb = {k.lower(): v for k, v in data.items()}
        elif isinstance(data, list):
            _kb = {
                item.get("question", "").lower(): item.get("answer", "")
                for item in data
                if isinstance(item, dict)
            }


_load_kb()  # Load at startup


# ── Auth dependency (optional) ─────────────────────────────────────────────
def _check_token(authorization: Optional[str] = Header(default=None)) -> None:
    if not SECRET_TOKEN:
        return
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")
    token = authorization.removeprefix("Bearer ").strip()
    if token != SECRET_TOKEN:
        raise HTTPException(status_code=403, detail="Invalid token")


# ── Request / Response models ───────────────────────────────────────────────
class AiraRequest(BaseModel):
    query: str
    context: Optional[str] = None   # Shloka text / verse reference / feature name
    persona: Optional[str] = "aira" # aira | krishna | guide


class AiraResponse(BaseModel):
    reply: str
    source: str  # "local_kb" | "gemini" | "fallback"
    persona: str


# ── Core logic: local keyword search ───────────────────────────────────────
def _local_search(query: str) -> Optional[str]:
    q = query.lower().strip()
    if q in _kb:
        return _kb[q]
    for key, answer in _kb.items():
        if q in key or key in q:
            return answer
    # Word-overlap scoring
    q_words = set(re.findall(r"\w+", q))
    best_score, best_answer = 0, None
    for key, answer in _kb.items():
        k_words = set(re.findall(r"\w+", key))
        score = len(q_words & k_words)
        if score > best_score:
            best_score, best_answer = score, answer
    return best_answer if best_score >= 2 else None


# ── Core logic: Gemini fallback ─────────────────────────────────────────────
async def _gemini_reply(query: str, context: Optional[str], persona: str) -> str:
    if not (_GEMINI_AVAILABLE and GEMINI_KEY):
        return (
            "I am Aira, your spiritual companion. My AI brain is resting — "
            "please check back soon or consult the app's offline knowledge."
        )

    system_map = {
        "krishna": "You are Lord Krishna from the Bhagavad Gita. Answer with divine wisdom.",
        "guide": "You are a knowledgeable Bhagavad Gita guide. Be clear and educational.",
        "aira": (
            "You are Aira, a warm and helpful AI support companion for the Geeta Nexus app. "
            "Answer questions about the app, the Bhagavad Gita, and spiritual practice. "
            "Be friendly, concise (under 120 words), and always encouraging."
        ),
    }
    system_prompt = system_map.get(persona, system_map["aira"])

    full_prompt = system_prompt
    if context:
        full_prompt += f"\n\nContext provided:\n{context}"
    full_prompt += f"\n\nUser question: {query}"

    model = genai.GenerativeModel(
        model_name="gemini-1.5-flash",
        generation_config={"temperature": 0.6, "max_output_tokens": 300},
    )
    response = model.generate_content(full_prompt)
    return response.text.strip()


# ── Routes ──────────────────────────────────────────────────────────────────
@app.get("/health")
def health():
    return {"status": "ok", "kb_entries": len(_kb), "gemini": _GEMINI_AVAILABLE and bool(GEMINI_KEY)}


@app.post("/ask", response_model=AiraResponse, dependencies=[Depends(_check_token)])
async def ask_aira(payload: AiraRequest) -> AiraResponse:
    """
    Universal ask endpoint.
    Accepts: { "query": "...", "context": "...", "persona": "aira|krishna|guide" }
    Returns: { "reply": "...", "source": "local_kb|gemini|fallback", "persona": "..." }

    This JSON contract is intentionally framework-agnostic — call it
    from Flutter, React Native, Jetpack Compose, or plain Java equally.
    """
    if not payload.query.strip():
        raise HTTPException(status_code=400, detail="Query cannot be empty")

    # 1. Try local knowledge base first (zero cost, instant)
    local = _local_search(payload.query)
    if local:
        return AiraResponse(reply=local, source="local_kb", persona=payload.persona or "aira")

    # 2. Combine query + context and call Gemini free tier
    try:
        reply = await _gemini_reply(
            payload.query, payload.context, payload.persona or "aira"
        )
        return AiraResponse(reply=reply, source="gemini", persona=payload.persona or "aira")
    except Exception as exc:
        # 3. Graceful offline fallback — never crash the client
        return AiraResponse(
            reply=(
                "I'm having a moment of stillness. "
                "Please try again or consult the Bhagavad Gita directly for guidance."
            ),
            source="fallback",
            persona=payload.persona or "aira",
        )


@app.post("/reload-kb", dependencies=[Depends(_check_token)])
def reload_kb() -> dict:
    """Hot-reload the knowledge base without restarting the server."""
    _load_kb()
    return {"status": "reloaded", "entries": len(_kb)}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
