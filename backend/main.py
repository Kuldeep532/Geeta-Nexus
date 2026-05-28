"""
Aira — Unified AI & Voice Backend
====================================
Single consolidated FastAPI backend for:
- AI chat (Gemini + local KB + Hugging Face fallback)
- Text-to-Speech (Hugging Face Inference API)
- Speech-to-Text (Hugging Face Inference API)
- Feedback email routing (SMTP or local log fallback)
"""

import os
import json
import re
import base64
import asyncio
import smtplib
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from pathlib import Path
from typing import Optional
from contextlib import asynccontextmanager
from datetime import datetime

from fastapi import FastAPI, HTTPException, Header, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, EmailStr
import httpx

logger = logging.getLogger("aira-backend")

# ── Optional Gemini import (graceful degradation) ─────────────────────────
try:
    import google.generativeai as genai
    _GEMINI_AVAILABLE = True
except ImportError:
    _GEMINI_AVAILABLE = False

# ── Config ─────────────────────────────────────────────────────────────────
GEMINI_KEY = os.environ.get("GEMINI_AI_API_KEY", "")
HF_API_KEY = os.environ.get("HF_API_KEY", "")
ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "*").split(",")
SECRET_TOKEN = os.environ.get("SECRET_TOKEN", "")

# SMTP config for feedback email routing
SMTP_HOST = os.environ.get("SMTP_HOST", "smtp.gmail.com")
SMTP_PORT = int(os.environ.get("SMTP_PORT", "587"))
SMTP_EMAIL = os.environ.get("SMTP_EMAIL", "")
SMTP_PASSWORD = os.environ.get("SMTP_PASSWORD", "")
FEEDBACK_DEST_EMAIL = os.environ.get("FEEDBACK_DEST_EMAIL", "kuldeepky538@gmail.com")

# Path for fallback local feedback log
_FEEDBACK_LOG = Path(__file__).parent / "feedback_log.json"

if _GEMINI_AVAILABLE and GEMINI_KEY:
    genai.configure(api_key=GEMINI_KEY)

# Hugging Face endpoints (public or dedicated)
HF_TTS_ENDPOINT = os.environ.get(
    "HF_TTS_ENDPOINT", "https://api-inference.huggingface.co/models/microsoft/speecht5_tts")
HF_STT_ENDPOINT = os.environ.get(
    "HF_STT_ENDPOINT", "https://api-inference.huggingface.co/models/openai/whisper-base")

# ── Knowledge base ──────────────────────────────────────────────────────────
_KB_PATH = Path(__file__).parent / "knowledge_base.json"
_kb: dict[str, str] = {}


def _load_kb() -> None:
    global _kb
    if _KB_PATH.exists():
        with open(_KB_PATH, encoding="utf-8") as f:
            data = json.load(f)
        if isinstance(data, dict):
            _kb = {k.lower(): v for k, v in data.items()}
        elif isinstance(data, list):
            _kb = {
                item.get("question", "").lower(): item.get("answer", "")
                for item in data
                if isinstance(item, dict)
            }


_load_kb()


# ── Auth dependency (optional bearer token) ────────────────────────────────
def _check_token(authorization: Optional[str] = Header(default=None)) -> None:
    if not SECRET_TOKEN:
        return
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")
    token = authorization.removeprefix("Bearer ").strip()
    if token != SECRET_TOKEN:
        raise HTTPException(status_code=403, detail="Invalid token")


# ── Pydantic Models ─────────────────────────────────────────────────────────
class AiraRequest(BaseModel):
    query: str
    context: Optional[str] = None
    persona: Optional[str] = "aira"


class AiraResponse(BaseModel):
    reply: str
    source: str
    persona: str


class TtsRequest(BaseModel):
    text: str
    voice: Optional[str] = "default"


class SttRequest(BaseModel):
    audio_base64: str
    language: Optional[str] = "en"


class FeedbackRequest(BaseModel):
    name: str
    email: str
    feedback: str


# ── Core logic: local keyword search ────────────────────────────────────────
def _local_search(query: str) -> Optional[str]:
    q = query.lower().strip()
    if q in _kb:
        return _kb[q]
    for key, answer in _kb.items():
        if q in key or key in q:
            return answer
    q_words = set(re.findall(r"\w+", q))
    best_score, best_answer = 0, None
    for key, answer in _kb.items():
        k_words = set(re.findall(r"\w+", key))
        score = len(q_words & k_words)
        if score > best_score:
            best_score, best_answer = score, answer
    return best_answer if best_score >= 2 else None


# ── Core logic: Gemini fallback ───────────────────────────────────────────
async def _gemini_reply(query: str, context: Optional[str], persona: str) -> str:
    if not (_GEMINI_AVAILABLE and GEMINI_KEY):
        return "AI brain is resting — please check back soon or consult offline knowledge."

    system_map = {
        "krishna": "You are Lord Krishna from the Bhagavad Gita. Answer with divine wisdom.",
        "guide": "You are a knowledgeable Bhagavad Gita guide. Be clear and educational.",
        "aira": (
            "You are Aira, a warm AI support companion for the Geeta Nexus app. "
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


# ── Core logic: Hugging Face fallback ───────────────────────────────────────
async def _hf_chat_reply(query: str, context: Optional[str], persona: str) -> str:
    if not HF_API_KEY:
        return "AI services unavailable. Please try again later."

    system_map = {
        "krishna": "You are Lord Krishna. Answer with divine wisdom from the Bhagavad Gita.",
        "guide": "You are a Gita guide. Be clear and educational.",
        "aira": "You are Aira, a warm spiritual AI companion. Be concise and encouraging.",
    }
    system = system_map.get(persona, system_map["aira"])
    prompt = f"{system}\n\nUser: {query}\nAssistant:"
    if context:
        prompt = f"{system}\n\nContext: {context}\n\nUser: {query}\nAssistant:"

    url = os.environ.get("HF_CHAT_ENDPOINT", "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2")
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(
            url,
            headers={"Authorization": f"Bearer {HF_API_KEY}"},
            json={"inputs": prompt, "parameters": {"max_new_tokens": 300, "temperature": 0.6}},
        )
        if resp.status_code == 200:
            data = resp.json()
            if isinstance(data, list) and len(data) > 0:
                text = data[0].get("generated_text", "")
                if text.startswith(prompt):
                    text = text[len(prompt):].strip()
                return text
        return "Hugging Face inference returned an unexpected response."


# ── Feedback: send email via SMTP or log locally ─────────────────────────────
def _send_feedback_email(name: str, email: str, feedback: str) -> bool:
    """Send feedback email via SMTP. Returns True on success."""
    if not SMTP_EMAIL or not SMTP_PASSWORD:
        return False

    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = f"[Gita Nexus Feedback] from {name}"
        msg["From"] = SMTP_EMAIL
        msg["To"] = FEEDBACK_DEST_EMAIL
        msg["Reply-To"] = email

        body = f"""
Gita Nexus App — New Feedback Submission
==========================================
Name:     {name}
Email:    {email}
Time:     {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

Feedback:
{feedback}
==========================================
        """.strip()

        msg.attach(MIMEText(body, "plain"))

        with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
            server.starttls()
            server.login(SMTP_EMAIL, SMTP_PASSWORD)
            server.sendmail(SMTP_EMAIL, FEEDBACK_DEST_EMAIL, msg.as_string())

        logger.info(f"Feedback email sent from {email}")
        return True
    except Exception as e:
        logger.error(f"SMTP error: {e}")
        return False


def _log_feedback_locally(name: str, email: str, feedback: str) -> None:
    """Append feedback to a local JSON log as fallback."""
    entry = {
        "timestamp": datetime.now().isoformat(),
        "name": name,
        "email": email,
        "feedback": feedback,
    }
    existing: list = []
    if _FEEDBACK_LOG.exists():
        try:
            existing = json.loads(_FEEDBACK_LOG.read_text(encoding="utf-8"))
        except Exception:
            existing = []
    existing.append(entry)
    _FEEDBACK_LOG.write_text(json.dumps(existing, indent=2, ensure_ascii=False), encoding="utf-8")
    logger.info(f"Feedback logged locally from {email}")


# ── FastAPI lifespan ────────────────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    _load_kb()
    yield


app = FastAPI(
    title="Aira — Gita Nexus Unified Backend",
    description="Single backend for AI chat, TTS, STT, and feedback routing.",
    version="2.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Routes ──────────────────────────────────────────────────────────────────
@app.get("/health")
def health():
    return {
        "status": "ok",
        "kb_entries": len(_kb),
        "gemini": _GEMINI_AVAILABLE and bool(GEMINI_KEY),
        "huggingface": bool(HF_API_KEY),
        "smtp_configured": bool(SMTP_EMAIL and SMTP_PASSWORD),
    }


@app.post("/ask", response_model=AiraResponse, dependencies=[Depends(_check_token)])
async def ask_aira(payload: AiraRequest) -> AiraResponse:
    if not payload.query.strip():
        raise HTTPException(status_code=400, detail="Query cannot be empty")

    # 1. Try local knowledge base (zero cost, instant)
    local = _local_search(payload.query)
    if local:
        return AiraResponse(reply=local, source="local_kb", persona=payload.persona or "aira")

    # 2. Try Gemini
    if _GEMINI_AVAILABLE and GEMINI_KEY:
        try:
            reply = await _gemini_reply(payload.query, payload.context, payload.persona or "aira")
            return AiraResponse(reply=reply, source="gemini", persona=payload.persona or "aira")
        except Exception:
            pass

    # 3. Fallback to Hugging Face
    if HF_API_KEY:
        try:
            reply = await _hf_chat_reply(payload.query, payload.context, payload.persona or "aira")
            return AiraResponse(reply=reply, source="huggingface", persona=payload.persona or "aira")
        except Exception:
            pass

    # 4. Graceful offline fallback
    return AiraResponse(
        reply="I am having a moment of stillness. Please try again or consult the Bhagavad Gita directly.",
        source="fallback",
        persona=payload.persona or "aira",
    )


@app.post("/tts")
async def tts(payload: TtsRequest):
    """Text-to-Speech via Hugging Face Inference API. Returns base64 audio."""
    if not HF_API_KEY:
        raise HTTPException(status_code=503, detail="HF_API_KEY not configured")

    async with httpx.AsyncClient(timeout=60) as client:
        resp = await client.post(
            HF_TTS_ENDPOINT,
            headers={"Authorization": f"Bearer {HF_API_KEY}"},
            json={"inputs": payload.text},
        )
        if resp.status_code != 200:
            raise HTTPException(status_code=502, detail=f"HF TTS error: {resp.status_code}")

        audio_bytes = resp.content
        return {"audio_base64": base64.b64encode(audio_bytes).decode(), "format": "audio/wav"}


@app.post("/stt")
async def stt(payload: SttRequest):
    """Speech-to-Text via Hugging Face Inference API. Accepts base64 audio."""
    if not HF_API_KEY:
        raise HTTPException(status_code=503, detail="HF_API_KEY not configured")

    audio_bytes = base64.b64decode(payload.audio_base64)

    async with httpx.AsyncClient(timeout=60) as client:
        resp = await client.post(
            HF_STT_ENDPOINT,
            headers={"Authorization": f"Bearer {HF_API_KEY}"},
            content=audio_bytes,
        )
        if resp.status_code != 200:
            raise HTTPException(status_code=502, detail=f"HF STT error: {resp.status_code}")

        data = resp.json()
        text = data.get("text", "") if isinstance(data, dict) else ""
        return {"text": text}


@app.post("/feedback")
async def submit_feedback(payload: FeedbackRequest):
    """
    Route feedback from the app directly to kuldeepky538@gmail.com.
    Uses SMTP if SMTP_EMAIL + SMTP_PASSWORD are set; otherwise logs locally.
    Returns 200 in both cases so the app always shows a success message.
    """
    name = payload.name.strip()
    email = payload.email.strip()
    feedback = payload.feedback.strip()

    if not name or not email or not feedback:
        raise HTTPException(status_code=400, detail="All fields are required")

    sent_by_email = _send_feedback_email(name, email, feedback)
    if not sent_by_email:
        _log_feedback_locally(name, email, feedback)

    return {
        "status": "received",
        "method": "email" if sent_by_email else "local_log",
        "message": "Thank you for your feedback. We will review it shortly.",
    }


@app.post("/reload-kb", dependencies=[Depends(_check_token)])
def reload_kb() -> dict:
    _load_kb()
    return {"status": "reloaded", "entries": len(_kb)}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
