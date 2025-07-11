const express = require('express');
const { HfInference } = require('@huggingface/inference');
const cors = require('cors');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware Setup
app.use(cors());
app.use(express.json());

// Initialize Hugging Face client with the token from environment variables
const hf = new HfInference(process.env.HF_TOKEN);

// Define the model we are using
const MODEL_NAME = 'llama3-8b-8192';

// --- API Endpoint for Single Analysis ---
app.post('/analyze', async (req, res) => {
  const { text } = req.body;
  if (!text) {
    return res.status(400).json({ error: 'Text is required' });
  }

  try {
    // Construct the precise prompt for the model
    const prompt = `[INST] You are a meticulous medical laboratory AI assistant. Your task is to analyze the provided lab report text and respond ONLY in clear, professional, well-formatted Arabic markdown. Your response must be structured with ONLY two headings: "**التفسير:**" and "**التوصيات:**". Do not add any extra text, greetings, or closing remarks. Here is the lab report text: \n\n${text} [/INST]`;

    const response = await hf.textGeneration({
      model: MODEL_NAME,
      inputs: prompt,
      parameters: {
        max_new_tokens: 1024,
        temperature: 0.7,
        return_full_text: false, // Important: prevents repeating the prompt in the answer
      }
    });

    res.json({ analysis: response.generated_text });

  } catch (error) {
    console.error('Error during analysis:', error);
    res.status(500).json({ error: 'Failed to analyze text' });
  }
});

// --- API Endpoint for Comparing Analyses ---
app.post('/compare', async (req, res) => {
    const { analysesTexts } = req.body;
    if (!analysesTexts || !Array.isArray(analysesTexts) || analysesTexts.length < 2) {
        return res.status(400).json({ error: 'Please provide at least two analyses to compare.' });
    }

    const combinedText = analysesTexts.map((text, index) => {
        return `--- Analysis ${index + 1} ---\n${text}\n\n`;
    }).join('');

    try {
        const prompt = `[INST] You are a meticulous medical laboratory AI assistant. Your task is to compare the provided lab reports and respond ONLY in clear, professional, well-formatted Arabic markdown. Your response must be structured with ONLY two headings: "**المقارنة:**" and "**التوصيات:**". Do not add any extra text, greetings, or closing remarks. Focus on trends and significant changes. Here are the lab reports:\n\n${combinedText} [/INST]`;

        const response = await hf.textGeneration({
            model: MODEL_NAME,
            inputs: prompt,
            parameters: {
                max_new_tokens: 1500, // Allow more tokens for comparison
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

// Start the server
app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
