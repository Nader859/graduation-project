const express = require('express');
const { HfInference } = require('@huggingface/inference');
const cors = require('cors');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// تهيئة Hugging Face باستخدام المفتاح الجديد
const hf = new HfInference(process.env.HF_TOKEN);

// تحديد اسم النموذج الذي تريده بالضبط
const MODEL_NAME = "meta-llama/Meta-Llama-3-8B-Instruct";

// نقطة النهاية لتحليل نص واحد
app.post('/analyze', async (req, res) => {
  const { text } = req.body;
  if (!text) {
    return res.status(400).json({ error: 'Text is required' });
  }

  try {
    // بناء الـ Prompt بالطريقة الصحيحة لنموذج Mistral
    const prompt = `[INST] You are an expert AI assistant for analyzing medical lab reports. Your response MUST be in well-formatted Arabic markdown and contain ONLY two sections: a "Interpretation" section and a "Recommendations" section. Start directly with the first heading. Do not add any introductions, greetings, or closing remarks. Use "**التفسير:**" for the interpretation heading and "**التوصيات:**" for the recommendations heading. Here is the lab report text: \n\n${text} [/INST]`;

    const response = await hf.textGeneration({
      model: MODEL_NAME,
      inputs: prompt,
      parameters: {
        max_new_tokens: 1024,
        temperature: 0.7,
        return_full_text: false, // لا نريد تكرار السؤال في الإجابة
      }
    });

    res.json({ analysis: response.generated_text });

  } catch (error) {
    console.error('Error during analysis:', error);
    res.status(500).json({ error: 'Failed to analyze text' });
  }
});

// نقطة النهاية لمقارنة عدة نصوص
app.post('/compare', async (req, res) => {
    const { analysesTexts } = req.body;
    if (!analysesTexts || !Array.isArray(analysesTexts) || analysesTexts.length < 2) {
        return res.status(400).json({ error: 'Please provide at least two analyses to compare.' });
    }

    const combinedText = analysesTexts.map((text, index) => {
        return `--- Analysis ${index + 1} ---\n${text}\n\n`;
    }).join('');

    try {
        const prompt = `[INST] You are an expert AI assistant for comparing medical lab reports. Your task is to compare the provided reports and respond ONLY in clear, professional, well-formatted Arabic markdown. Your response must be structured with ONLY two headings: "**المقارنة:**" and "**التوصيات:**". Do not add any extra text, greetings, or closing remarks. Here are the lab reports:\n\n${combinedText} [/INST]`;

        const response = await hf.textGeneration({
            model: MODEL_NAME,
            inputs: prompt,
            parameters: {
                max_new_tokens: 1500,
                temperature: 0.7,
                return_full_text: false,
            }
        });

        res.json({ comparison: response.generated_text });

    } catch (error) {
        console.error('Error during comparison:', error);
        res.status(500).json({ error: 'Failed to get comparison' });
    }
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
