import { GoogleGenAI } from "@google/genai";

/**
 * Analyzes clothing item image using Gemini Vision API
 * @param {string} base64ImageData - Base64 encoded image data (with or without data URI prefix)
 * @returns {Promise<string>} Description of the clothing item
 */
export const analyzeClothingImage = async (base64ImageData) => {
    if (!process.env.GOOGLE_API_KEY) {
        throw new Error("GOOGLE_API_KEY not set");
    }

    console.log("starting gemini call");
    const genAI = new GoogleGenAI({ apiKey: process.env.GOOGLE_API_KEY });

    // Cleans data prefixes
    const cleanBase64 = base64ImageData.replace(
        /^data:image\/[^;]+;base64,/,
        ""
    );

    try {
        const contents = [
            {
                inlineData: {
                    mimeType: "image/jpeg",
                    data: cleanBase64,
                },
            },
            { text: "describe the clothes on this image" },
        ];
        console.log("starting api call");
        const response = await genAI.models.generateContent({
            model: "gemini-2.0-flash",
            contents: contents,
        });

        const description = response.text;

        return description;
    } catch (error) {
        console.error("Gemini API Error:", error);
        throw new Error(`Gemini API Error: ${error.message}`);
    }
};
