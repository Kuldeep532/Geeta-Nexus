# Aira Backend — Node.js / Next.js

Stateless, serverless-ready backend for the Aira Voice Support feature.

## Deploy on Vercel (Free)

1. Push this `backend-node/` folder to its own GitHub repo (or a monorepo).
2. Go to https://vercel.com → New Project → import the repo.
3. Set the environment variable in Vercel dashboard:
   - `GROQ_API_KEY` → get a free key from https://console.groq.com (no credit card needed)
4. Deploy. Copy the URL (e.g. `https://aira-backend.vercel.app`).
5. In your Flutter app, build with:
   ```
   flutter build web --dart-define=AIRA_BACKEND_URL=https://aira-backend.vercel.app
   ```

## API

**POST /api/chat**

Request body:
```json
{ "message": "How do I use the Karma Planner?" }
```

Response:
```json
{ "reply": "The Karma Planner helps you plan your day through Krishna's teachings..." }
```

## Local dev

```bash
npm install
npm run dev
```
