const express = require('express');
const Groq = require('groq-sdk');
const cors = require('cors');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// تهيئة Groq باستخدام المفتاح من متغيرات البيئة
const groq = new Groq({
    apiKey: process.env.GROQ_API_KEY,
});

// تحديد النموذج المستقر الذي سنستخدمه
const MODEL_NAME = 'mistralai/Mistral-7B-Instruct-v0.2';

// --- نقطة النهاية لتحليل نص واحد ---
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
                    content: 'You are a meticulous medical laboratory AI assistant. Your task is to analyze the provided lab report text and respond ONLY in clear, professional, well-formatted Arabic markdown. Your response must be structured with ONLY two headings: "**التفسير:**" and "**التوصيات:**". Do not add any extra text, greetings, or closing remarks.',
                },
                {
                    role: 'user',
                    content: text,
                },
            ],
            model: MODEL_NAME,
        });

        res.json({ analysis: chatCompletion.choices[0]?.message?.content || '' });
    } catch (error) {
        console.error('Error during analysis:', error);
        res.status(500).json({ error: 'Failed to analyze text' });
    }
});

// --- نقطة النهاية لمقارنة عدة نصوص ---
app.post('/compare', async (req, res) => {
    const { analysesTexts } = req.body;
    if (!analysesTexts || !Array.isArray(analysesTexts) || analysesTexts.length < 2) {
        return res.status(400).json({ error: 'Please provide at least two analyses to compare.' });
    }

    const combinedText = analysesTexts.map((text, index) => {
        return `--- Analysis ${index + 1} ---\n${text}\n\n`;
    }).join('');

    try {
        const chatCompletion = await groq.chat.completions.create({
            messages: [
                {
                    role: 'system',
                    content: 'You are a meticulous medical laboratory AI assistant. Your task is to compare the provided lab reports and respond ONLY in clear, professional, well-formatted Arabic markdown. Your response must be structured with ONLY two headings: "**المقارنة:**" and "**التوصيات:**". Do not add any extra text, greetings, or closing remarks. Focus on trends and significant changes.',
                },
                {
                    role: 'user',
                    content: combinedText,
                },
            ],
            model: MODEL_NAME,
        });

        res.json({ comparison: chatCompletion.choices[0]?.message?.content || '' });
    } catch (error) {
        console.error('Error during comparison:', error);
        res.status(500).json({ error: 'Failed to get comparison' });
    }
});

// Start the server
app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});

