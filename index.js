const express = require('express');
const Groq = require('groq-sdk');
const cors = require('cors');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// استخدام cors للسماح بالطلبات من أي مصدر
app.use(cors());
app.use(express.json());

// تهيئة Groq
const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

// نقطة النهاية الرئيسية للتحقق من أن الخادم يعمل
app.get('/', (req, res) => {
  res.send('Lab Analysis API is running!');
});

// نقطة النهاية لتحليل النص
app.post('/analyze', async (req, res) => {
  const { text } = req.body;

  if (!text) {
    return res.status(400).json({ error: 'Text is required' });
  }

  try {
const chatCompletion = await groq.chat.completions.create({
    messages: [
        {
            role: 'system',
            content: 'You are an expert AI assistant for analyzing medical lab reports. Your response MUST be in well-formatted Arabic markdown. Use bullet points for recommendations (using - or *). Use bold text for titles or important terms (using **term**). Go straight to the analysis without any introductory or concluding pleasantries like "Hello" or "I hope this helps".',
        },
        {
            role: 'user',
            content: text,
        },
    ],
    // استخدم النموذج الذي تفضله بالاسم الصحيح على Groq
    model: 'mistral-7b-instruct', 
});

    const analysisResult = chatCompletion.choices[0]?.message?.content || 'No result';
    res.json({ analysis: analysisResult });
  } catch (error) {
    console.error('Error calling Groq API:', error);
    res.status(500).json({ error: 'Failed to analyze text' });
  }
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
