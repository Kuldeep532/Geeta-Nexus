# Aira — Universal AI Backend

Lightweight FastAPI backend for the **Aira** conversational support agent in the Geeta Nexus app.

## Architecture

```
Flutter / React Native / Jetpack Compose
          │
          │  POST /ask  { query, context, persona }
          ▼
    ┌──────────────────────┐
    │   FastAPI (Python)   │
    │   Aira Core Engine   │
    │  ─────────────────── │
    │  1. Local KB search  │  ← FREE, instant, offline-capable
    │  2. Gemini 1.5 Flash │  ← FREE tier (15 req/min, 1M tok/day)
    │  3. Graceful fallback│  ← Never crashes the client
    └──────────────────────┘
```

The request/response contract is **pure JSON** — making this backend 100% re-usable from Flutter, React Native, native Android/Java, or any future framework.

## Zero-Cost Stack

| Layer | Technology | Cost |
|-------|-----------|------|
| API server | FastAPI + Uvicorn | Free |
| Hosting | Render free tier / HuggingFace Spaces | Free |
| LLM | Google Gemini 1.5 Flash (free tier) | Free |
| Knowledge base | Local JSON file | Free |
| Voice (TTS/STT) | flutter_tts + speech_to_text (device-native) | Free |

## Quick Start

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Set environment variables (never hardcode)
export GEMINI_AI_API_KEY="your_key_here"
export SECRET_TOKEN="optional_bearer_token"
export ALLOWED_ORIGINS="https://yourapp.com,http://localhost"

# 3. Run
python main.py
# or: uvicorn main:app --reload
```

## API Reference

### `POST /ask`
Ask Aira a question.

**Request:**
```json
{
  "query": "What is karma yoga?",
  "context": "Chapter 3, Verse 5 — optional shloka context",
  "persona": "aira"
}
```
`persona` options: `aira` | `krishna` | `guide`

**Response:**
```json
{
  "reply": "Karma Yoga is the path of selfless action...",
  "source": "local_kb",
  "persona": "aira"
}
```
`source` values: `local_kb` | `gemini` | `fallback`

### `GET /health`
Returns server health and KB entry count.

### `POST /reload-kb`
Hot-reloads `knowledge_base.json` without restart.

## Knowledge Base

Edit `knowledge_base.json` to add domain-specific Q&A pairs. Format:
```json
[
  { "question": "your question here", "answer": "answer here" }
]
```
The engine accepts **any domain** — swap the Gita KB for a different app's data without changing a line of backend code.

## Deploy to Render (Free)

1. Push this `backend/` folder to a GitHub repository.
2. Create a **Web Service** on [render.com](https://render.com) pointing to it.
3. Set **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
4. Add environment variables in Render's dashboard (never in code).
5. Copy the deploy hook URL → add as `RENDER_DEPLOY_HOOK` GitHub secret for auto-deploy via CI.

## Security

- All secrets come from environment variables only — zero hardcoding.
- Optional `SECRET_TOKEN` bearer token protects the `/ask` endpoint.
- CORS origins are configurable via `ALLOWED_ORIGINS` env var.
