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
    model: 'llama3-8b-8192', 
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
    const chatCompletion = await groq.chat.completions.create({
      messages: [
        {
          role: 'system',
          content: 'You are an expert AI assistant for comparing medical lab reports. The user will provide you with several reports separated by "---". Your task is to: 1. Compare the similar tests across the reports. 2. Highlight any trends, improvements, or deteriorations in the values. 3. Provide a clear, concise summary of the changes in well-formatted Arabic markdown. Use bullet points and bold text.',
        },
        {
          role: 'user',
          content: combinedText,
        },
      ],
      model: 'llama3-8b-8192', // استخدام نفس النموذج المتاح حالياً
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
