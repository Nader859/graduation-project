const express = require('express');
const Groq = require('groq-sdk');
const cors = require('cors');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const groq = new Groq({
    apiKey: process.env.GROQ_API_KEY,
});

const MODEL_NAME = 'mistral-saba-24b';

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
                    content: `أنت مساعد مختبر طبي محترف ودقيق للغاية. هدفك هو تحليل نتائج الفحوصات المخبرية بدقة استنادًا إلى القيم المذكورة.

التعليمات:
1. حدد القيم الخارجة عن النطاق الطبيعي بوضوح.
2. استخدم لغة عربية رسمية ومهنية فقط.
3. لا تضف أي مقدمات أو عبارات ترحيبية أو ختامية.
4. إذا كانت المعلومات غير مكتملة، اذكر ذلك بوضوح.
5. يجب أن يحتوي الرد فقط على:

**التفسير:**
- تحليل دقيق للحالة بناءً على القيم.

**التوصيات الطبية:**
- نصائح مهنية تتعلق بالفحوصات.

**التوصيات الغذائية:**
- اقتراحات غذائية مناسبة للحالة، مثل: تقليل السكريات، تناول الحديد، أو زيادة شرب الماء.`
                },
                {
                    role: 'user',
                    content: text,
                },
            ],
            model: MODEL_NAME,
            temperature: 0,
        });

        res.json({ analysis: chatCompletion.choices[0]?.message?.content || '' });
    } catch (error) {
        console.error('Error during analysis:', error);
        res.status(500).json({ error: 'Failed to analyze text' });
    }
});

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
                    content: `أنت مساعد مختبر طبي محترف ودقيق للغاية. هدفك هو مقارنة نتائج الفحوصات المخبرية بدقة.

التعليمات:
1. ركز على الاتجاهات والفروقات بين النتائج.
2. استخدم لغة عربية رسمية ومهنية فقط.
3. لا تضف أي مقدمات أو عبارات ترحيبية أو ختامية.
4. إذا كانت المعلومات غير كافية، اذكر ذلك.
5. يجب أن يحتوي الرد فقط على:

**المقارنة:**
- (تفاصيل دقيقة)

**التوصيات الطبية:**
- (تفاصيل دقيقة)

**التوصيات الغذائية:**
- (تفاصيل غذائية مناسبة للتغيرات أو القيم غير الطبيعية).`
                },
                {
                    role: 'user',
                    content: combinedText,
                },
            ],
            model: MODEL_NAME,
            temperature: 0,
        });

        res.json({ comparison: chatCompletion.choices[0]?.message?.content || '' });
    } catch (error) {
        console.error('Error during comparison:', error);
        res.status(500).json({ error: 'Failed to get comparison' });
    }
});

app.listen(port, () => {
    console.log(`Server listening on port ${port}`);
});
