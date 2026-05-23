export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { message } = req.body || {};
  if (!message || typeof message !== 'string' || message.trim() === '') {
    return res.status(400).json({ error: 'message is required' });
  }

  const systemPrompt = `You are Aira, a warm and knowledgeable customer support assistant for Geeta Nexus — a spiritual app based on the Bhagavad Gita and Vedic scriptures. Answer helpfully and concisely in 2-4 sentences. If the question is spiritual, draw from Gita wisdom. If it is a technical app question, give clear practical guidance.`;

  try {
    const groqKey = process.env.GROQ_API_KEY;
    if (!groqKey) {
      return res.status(200).json({
        reply: 'Thank you for reaching out. Our support team will respond shortly. For immediate help, explore the app\'s built-in guidance features.',
      });
    }

    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${groqKey}`,
      },
      body: JSON.stringify({
        model: 'llama-3.1-8b-instant',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: message.trim() },
        ],
        max_tokens: 200,
        temperature: 0.6,
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      console.error('Groq error:', err);
      return res.status(200).json({ reply: 'I am momentarily unavailable. Please try again in a moment.' });
    }

    const data = await response.json();
    const reply = data?.choices?.[0]?.message?.content ?? 'I could not generate a response. Please try again.';
    return res.status(200).json({ reply });
  } catch (err) {
    console.error('Handler error:', err);
    return res.status(200).json({ reply: 'A connection error occurred. Please check your network and try again.' });
  }
}
