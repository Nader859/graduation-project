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
// The new code block for /analyze
const chatCompletion = await groq.chat.completions.create({
    messages: [
        {
            role: 'system',
            content: 'You are a meticulous medical laboratory AI assistant. Your task is to analyze the provided lab report text and respond ONLY in clear, professional, well-formatted Arabic markdown. Your response must be structured with ONLY two headings: "**التفسير:**" and "**التوصيات:**". Do not add any extra text, greetings, or closing remarks. Be accurate and concise.',
        },
        {
            role: 'user',
            content: text,
        },
    ],
    model: 'mixtral-8x7b-32768', // <-- النموذج الجديد والأقوى
});

    const analysisResult = chatCompletion.choices[0]?.message?.content || 'No result';
    res.json({ analysis: analysisResult });
  } catch (error) {
    console.error('Error calling Groq API:', error);
    res.status(500).json({ error: 'Failed to analyze text' });
  }
});
// ▼▼▼ أضف هذا الكود الجديد هنا ▼▼▼
app.post('/compare', async (req, res) => {
  // نستقبل مصفوفة من نصوص التحاليل من التطبيق
  const { analysesTexts } = req.body;

  // نتأكد من أننا استقبلنا تحليلين على الأقل
  if (!analysesTexts || !Array.isArray(analysesTexts) || analysesTexts.length < 2) {
    return res.status(400).json({ error: 'Please provide at least two analyses to compare.' });
  }

  // نجمع النصوص مع فواصل لتكون واضحة للـ AI
  const combinedText = analysesTexts.map((text, index) => {
    return `--- التحليل رقم ${index + 1} ---\n${text}\n\n`;
  }).join('');

  try {
    // نرسل الطلب لنموذج الذكاء الاصطناعي مع تعليمات جديدة خاصة بالمقارنة
// The old code block for /compare
// The new code block for /compare
const chatCompletion = await groq.chat.completions.create({
    messages: [
        {
            role: 'system',
            content: 'You are an expert AI assistant for comparing medical lab reports. Your response MUST be in well-formatted Arabic markdown and contain ONLY two sections: a "Comparison" section and a "Recommendations" section...',
            content: 'You are a meticulous medical laboratory AI assistant. Your task is to compare the provided lab reports and respond ONLY in clear, professional, well-formatted Arabic markdown. Your response must be structured with ONLY two headings: "**المقارنة:**" and "**التوصيات:**". Do not add any extra text, greetings, or closing remarks. Focus on trends and significant changes.',
        },
        {
            role: 'user',
            content: combinedText,
        },
    ],
    model: 'llama3-8b-8192',
    model: 'mixtral-8x7b-32768', // <-- النموذج الجديد والأقوى
});

    const comparisonResult = chatCompletion.choices[0]?.message?.content || 'No comparison result';
    res.json({ comparison: comparisonResult });

  } catch (error) {
    console.error('Error during comparison:', error);
    res.status(500).json({ error: 'Failed to get comparison' });
  }
});
// ▲▲▲ نهاية الكود الجديد ▲▲▲
app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
