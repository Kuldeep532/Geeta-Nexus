// Verification Public Key (Ed25519)
const PUBLIC_KEY_BASE64 = "MCowBQYDK2VwAyEAa4ZxuobCuaSe+HMbCc7YW7AG/W5SELvpc7NNBVX9ab4=";

// Base64 string ko ArrayBuffer mein convert karne ka helper
function base64ToArrayBuffer(base64) {
  const binaryString = atob(base64);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
}

// CryptoKey Object Cache & Import
let cachedPublicKey = null;
async function getPublicKey() {
  if (!cachedPublicKey) {
    const keyBuffer = base64ToArrayBuffer(PUBLIC_KEY_BASE64);
    cachedPublicKey = await crypto.subtle.importKey(
      "spki",
      keyBuffer,
      { name: "Ed25519" },
      false,
      ["verify"]
    );
  }
  return cachedPublicKey;
}

export default {
  async fetch(request, env, ctx) {
    const allowedOrigin = "https://nexusweb.co.in";
    const requestOrigin = request.headers.get("Origin");

    const corsHeaders = {
      "Access-Control-Allow-Origin": requestOrigin === allowedOrigin ? allowedOrigin : "",
      "Access-Control-Allow-Methods": "GET, HEAD, POST, OPTIONS",
      "Access-Control-Allow-Headers": "X-API-Name, Content-Type, X-Timestamp, X-Nonce, X-Signature, Authorization",
      "X-Content-Type-Options": "nosniff",
      "X-Frame-Options": "DENY",
      "Content-Security-Policy": "default-src 'none';"
    };

    // CORS Preflight Handling
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      // 1. Mandatory Headers Extract Karein
      const apiName = request.headers.get("X-API-Name");
      const timestamp = request.headers.get("X-Timestamp");
      const nonce = request.headers.get("X-Nonce");
      const signatureHex = request.headers.get("X-Signature");

      if (!apiName || !timestamp || !nonce || !signatureHex) {
        return new Response(JSON.stringify({ 
          status: "blocked", 
          error: "Missing required authentication headers." 
        }), { 
          status: 401, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        });
      }

      // 2. Anti-Replay Attack Check (Request time window: 5 mins)
      const requestTime = parseInt(timestamp, 10);
      const currentTime = Math.floor(Date.now() / 1000);
      if (isNaN(requestTime) || Math.abs(currentTime - requestTime) > 300) {
        return new Response(JSON.stringify({ 
          status: "blocked", 
          error: "Request timestamp is invalid or expired." 
        }), { 
          status: 403, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        });
      }

      // 3. Digital Signature Verification
      // Signature Payload: "apiName:timestamp:nonce"
      const messageToVerify = `${apiName}:${timestamp}:${nonce}`;
      const encoder = new TextEncoder();
      const dataBuffer = encoder.encode(messageToVerify);

      // Signature Hex ko Uint8Array mein convert karein
      const signatureBytes = new Uint8Array(
        signatureHex.match(/.{1,2}/g)?.map(byte => parseInt(byte, 16)) || []
      );

      const publicKey = await getPublicKey();
      const isValid = await crypto.subtle.verify(
        { name: "Ed25519" },
        publicKey,
        signatureBytes,
        dataBuffer
      );

      if (!isValid) {
        return new Response(JSON.stringify({ 
          status: "blocked",
          message_hn: "आपकी डिजिटल सिग्नेचर सत्यापन विफल रही। कृपया ओरिजिनल ऐप का उपयोग करें!",
          message_en: "Digital signature verification failed. Please use the original app!"
        }), { 
          status: 403, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        });
      }

      // 4. API Registry/Data Fetching
      let apiData = null;
      if (env[apiName]) {
        apiData = env[apiName];
      } else if (env.API_REGISTRY) {
        apiData = await env.API_REGISTRY.get(apiName);
      }

      if (!apiData) {
        return new Response(JSON.stringify({ error: `API Key for '${apiName}' not found` }), { 
          status: 404, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        });
      }

      // Successful Response
      return new Response(JSON.stringify({
        status: "success",
        requested_api: apiName,
        api_key: apiData
      }), {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
          "Cache-Control": "private, no-store, no-cache, must-revalidate"
        }
      });

    } catch (error) {
      return new Response(JSON.stringify({ error: "Execution Failed" }), { 
        status: 500, 
        headers: { ...corsHeaders, "Content-Type": "application/json" } 
      });
    }
  }
};
