# Deprecated: Node backend removed from active app flow

This repository now uses a **single backend server** for Aira AI support:
- `backend/` (FastAPI) with `POST /ask`

The Flutter app's Voice Support screen calls:
- `--dart-define=AIRA_API_URL=https://your-fastapi-host`

If this folder is still present, treat it as legacy reference only.
