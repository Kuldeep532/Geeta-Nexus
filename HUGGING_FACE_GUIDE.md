# Hugging Face Integration Guide for Gita Nexus

## Overview

Gita Nexus uses the **Hugging Face Inference API** for all AI voice (TTS/STT) and chat fallback operations. This guide explains how the integration works and how to set it up.

## Architecture

```
Flutter Web App
      |
      v
[HuggingFaceVoiceService]  <-- HTTP -->  [Hugging Face Inference API]
      |                                          |
      v                                          v
[TTS] microsoft/speecht5_tts              [STT] openai/whisper-base
[Chat Fallback] mistralai/Mistral-7B      [Fallback Chat] HF Spaces
```

## 1. Getting Your Hugging Face API Token

1. Create an account at https://huggingface.co/join
2. Go to Profile → Settings → Access Tokens
3. Click "New Token"
4. Name it "Gita Nexus" and select role: `read`
5. Copy the token immediately (it won't be shown again)

## 2. Setting the API Key

Add the token to your Replit Secrets (or `.env` file for local development):

```
HF_API_KEY=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

The key is read at compile time via:
```dart
static const String _hfApiKey = String.fromEnvironment('HF_API_KEY');
```

## 3. Text-to-Speech (TTS)

### Default Model
- **Model**: `microsoft/speecht5_tts`
- **Endpoint**: `https://api-inference.huggingface.co/models/microsoft/speecht5_tts`
- **Input**: JSON `{"inputs": "Your text here"}`
- **Output**: Raw audio bytes (WAV format)

### How It Works in Code
```dart
// lib/services/huggingface_voice_service.dart
Future<Uint8List?> synthesize(String text) async {
  final response = await http.post(
    Uri.parse('https://api-inference.huggingface.co/models/microsoft/speecht5_tts'),
    headers: {
      'Authorization': 'Bearer $_hfApiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'inputs': text}),
  );
  if (response.statusCode == 200) return response.bodyBytes;
  return null;
}
```

### Playing the Audio
On web, the audio bytes are converted to a Blob URL and played via `AudioElement`:
```dart
final blob = html.Blob([bytes], 'audio/wav');
final url = html.Url.createObjectUrlFromBlob(blob);
_audioElement = html.AudioElement(url)..play();
```

## 4. Speech-to-Text (STT)

### Default Model
- **Model**: `openai/whisper-base` (or `openai/whisper-small` for better accuracy)
- **Endpoint**: `https://api-inference.huggingface.co/models/openai/whisper-base`
- **Input**: Audio file (WAV/MP3/FLAC) as multipart form-data
- **Output**: JSON `{"text": "transcribed text"}`

### How It Works in Code
```dart
Future<String?> transcribe(Uint8List audioBytes) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('https://api-inference.huggingface.co/models/openai/whisper-base'),
  );
  request.headers['Authorization'] = 'Bearer $_hfApiKey';
  request.files.add(http.MultipartFile.fromBytes(
    'file', audioBytes, filename: 'audio.wav',
  ));
  final response = await request.send();
  if (response.statusCode == 200) {
    final body = jsonDecode(await response.stream.bytesToString());
    return body['text'];
  }
  return null;
}
```

### Web Recording
On Flutter Web, we use the Web Audio API via `dart:html`:
```dart
// Start recording
_mediaRecorder = html.MediaRecorder(_stream);
_mediaRecorder!.onDataAvailable.listen((e) {
  _chunks.add(e.data as html.Blob);
});
_mediaRecorder!.start();

// Stop and get bytes
_mediaRecorder!.stop();
final blob = html.Blob(_chunks, 'audio/webm');
final reader = html.FileReader();
reader.readAsArrayBuffer(blob);
```

## 5. AI Chat Fallback

When the primary backend (Gemini) is unavailable, the app falls back to Hugging Face:

### Model
- **Default**: `mistralai/Mistral-7B-Instruct-v0.2`
- **Alternative**: `meta-llama/Llama-2-7b-chat-hf`

### Request Format
```json
{
  "inputs": "[INST] You are Aira, a spiritual guide based on the Bhagavad Gita.\n\nUser: What does Krishna say about duty? [/INST]",
  "parameters": {
    "max_new_tokens": 300,
    "temperature": 0.6,
    "return_full_text": false
  }
}
```

### Backend Endpoint
The unified FastAPI backend (`backend/main.py`) proxies to Hugging Face:
```python
@app.post("/ask")
async def ask(request: AskRequest):
    # 1. Try local knowledge base
    # 2. Try Gemini
    # 3. Fallback to Hugging Face Inference API
    response = await hf_chat_fallback(request.question)
    return AiraResponse(answer=response, source="huggingface")
```

## 6. Dedicated Inference Endpoints (Production)

For production use with guaranteed uptime and lower latency, create dedicated endpoints:

1. Go to https://huggingface.co/inference-endpoints
2. Create endpoints for each model:
   - **TTS**: `microsoft/speecht5_tts` → copy URL as `HF_TTS_ENDPOINT`
   - **STT**: `openai/whisper-base` → copy URL as `HF_STT_ENDPOINT`
   - **Chat**: `mistralai/Mistral-7B-Instruct-v0.2` → copy URL as `HF_CHAT_ENDPOINT`
3. Add these to your environment variables
4. The code automatically uses dedicated endpoints when available:
```dart
final endpoint = const String.fromEnvironment('HF_TTS_ENDPOINT')
    .ifEmpty('https://api-inference.huggingface.co/models/microsoft/speecht5_tts');
```

## 7. Rate Limits & Pricing

### Free Tier (Shared Inference API)
- **Rate limit**: ~10 requests/minute per model
- **No guaranteed uptime**: Models may be "warming up" after periods of inactivity
- **Cost**: Free

### Pro Tier (Dedicated Endpoints)
- **Rate limit**: Configurable (up to thousands of requests/minute)
- **Guaranteed uptime**: 99.9% SLA
- **Cost**: ~$0.06/hour per endpoint (scales with instance size)

### Recommended for Production
Use dedicated endpoints for TTS and STT (latency-critical). Chat fallback can use the free tier since it's only used when Gemini fails.

## 8. Troubleshooting

### "Model is currently loading" Error
The free tier loads models on-demand. First request after inactivity may take 10-30 seconds. Retry with exponential backoff.

### "Authorization failed" Error
- Verify your `HF_API_KEY` is correct and has `read` permissions
- Check the token hasn't expired (tokens are valid indefinitely unless revoked)

### Audio Not Playing on Web
- Ensure the browser allows autoplay (user interaction required first)
- Check the audio format: HF TTS returns WAV, which is supported by all browsers
- Use the Blob URL approach shown above rather than base64 data URLs

### STT Returns Empty Text
- Ensure audio is at least 1 second long
- Whisper works best with 16kHz sample rate
- Check the audio file isn't corrupted (test with a known-good file)

## 9. Complete Environment Variables

```bash
# Required
HF_API_KEY=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Optional — dedicated endpoints for production
HF_TTS_ENDPOINT=https://your-endpoint.huggingface.cloud
HF_STT_ENDPOINT=https://your-endpoint.huggingface.cloud
HF_CHAT_ENDPOINT=https://your-endpoint.huggingface.cloud

# Gemini fallback (also required)
GEMINI_AI_API_KEY=your_gemini_key_here
```

## 10. File Structure

```
lib/
  services/
    huggingface_voice_service.dart   # TTS + STT client
    ai_service.dart                  # Chat + backend client
backend/
  main.py                           # FastAPI proxy + fallback logic
```
