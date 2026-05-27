# Gita Nexus — Deployment Guide

## Architecture

Single unified FastAPI backend (`backend/main.py`) serving:
- `/ask` — AI chat with local KB → Gemini → Hugging Face fallback chain
- `/tts` — Text-to-Speech via Hugging Face Inference API
- `/stt` — Speech-to-Text via Hugging Face Inference API
- `/health` — Service health check

Frontend: Flutter Web compiled to static assets and served via `npx serve`.

## Required Secrets

Set these in Replit Secrets (or your deployment platform):

| Secret | Purpose |
|--------|---------|
| `GEMINI_AI_API_KEY` | Google Gemini 1.5 Flash for AI chat fallback |
| `HF_API_KEY` | Hugging Face API token for TTS/STT/chat inference |
| `SECRET_TOKEN` | Optional bearer token to protect `/ask`, `/tts`, `/stt` |
| `ADMIN_LOGIN_PASSWORD` | Admin dashboard access password |

## Hugging Face Setup

### 1. Create a Hugging Face Account
Go to https://huggingface.co/join and sign up.

### 2. Generate an API Token
- Profile → Settings → Access Tokens → New Token
- Select `read` role for inference endpoints
- Copy the token and set it as `HF_API_KEY`

### 3. Deploy Inference Endpoints (Optional but Recommended)
For production-grade low latency:
- Go to https://huggingface.co/inference-endpoints
- Deploy:
  - **TTS**: `microsoft/speecht5_tts` (or `facebook/fastspeech2-en-ljspeech`)
  - **STT**: `openai/whisper-base` (or `openai/whisper-small` for better accuracy)
  - **Chat**: `mistralai/Mistral-7B-Instruct-v0.2` (or `meta-llama/Llama-2-7b-chat-hf`)
- Copy each endpoint URL and set environment variables:
  - `HF_TTS_ENDPOINT`
  - `HF_STT_ENDPOINT`
  - `HF_CHAT_ENDPOINT`

### 4. Free Tier Alternative
If not using dedicated endpoints, the backend falls back to the free shared Hugging Face Inference API:
- `https://api-inference.huggingface.co/models/{model_id}`
- Rate limits apply (no guaranteed uptime)

## Replit Deployment

1. Set secrets in the Replit Secrets panel.
2. The workflow `Start application` runs `bash scripts/start.sh` which:
   - Runs `flutter pub get`
   - Builds with `--dart-define=GEMINI_AI_API_KEY=$GEMINI_AI_API_KEY`
   - Serves `build/web` on port 5000
3. The `.replit` deployment config publishes `build/web` as a static site.

## Backend-Only Deployment (Render / Fly.io / Railway)

```bash
cd backend
pip install -r requirements.txt
export GEMINI_AI_API_KEY=...
export HF_API_KEY=...
uvicorn main:app --host 0.0.0.0 --port 8000
```

The FastAPI backend is stateless and can be scaled horizontally.

## Security Checklist

- [ ] No API keys in source code
- [ ] All secrets via environment variables
- [ ] `SECRET_TOKEN` set for production backend
- [ ] CORS `ALLOWED_ORIGINS` restricted to your domain
