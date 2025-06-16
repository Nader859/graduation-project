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
          content: 'You are a helpful AI assistant specialized in analyzing medical lab reports for a user in the Middle East. Your task is to provide a simplified explanation and general recommendations in clear, easy-to-understand Arabic. Focus on values that are out of the normal range. IMPORTANT: DO NOT provide a medical diagnosis. Only recommend consulting a doctor for significantly abnormal values. Start your response with a clear summary.',
        },
        {
          role: 'user',
          content: text,
        },
      ],
model: 'llama3-8b-8192',    });

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
