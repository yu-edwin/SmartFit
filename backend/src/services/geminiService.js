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

/**
 * Generates an outfit image using Gemini API
 * @param {string} prompt - Text prompt describing the outfit items
 * @param {string} picture - Base64 encoded image of the user
 * @returns {Promise<string>} Generated outfit image
 */
export const generateOutfitImage = async (prompt, picture) => {
    if (!process.env.GOOGLE_API_KEY) {
        throw new Error("GOOGLE_API_KEY not set");
    }

    console.log("Starting generateOutfitImage");
    const genAI = new GoogleGenAI({ apiKey: process.env.GOOGLE_API_KEY });

    // Clean base64 data prefix
    const cleanBase64 = picture.replace(/^data:image\/[^;]+;base64,/, "");

    try {
        const contents = [
            {
                inlineData: {
                    mimeType: "image/jpeg",
                    data: cleanBase64,
                },
            },
            {
                text: `Generate an outfit visualization on this person wearing the following items: ${prompt}`,
            },
        ];

        console.log("Starting Gemini API call for outfit generation");
        const response = await genAI.models.generateContent({
            model: "gemini-2.5-flash-image",
            contents: contents,
        });

        console.log("Gemini API response received");

        // Extract image from inlineData
        if (response.candidates && response.candidates[0]?.content?.parts) {
            const parts = response.candidates[0].content.parts;
            console.log(`Response has ${parts.length} parts`);

            for (const part of parts) {
                if (part.inlineData) {
                    console.log(
                        `Found inlineData with mimeType: ${part.inlineData.mimeType}`
                    );
                    // Return base64 image with data URL prefix
                    const base64Image = `data:${part.inlineData.mimeType};base64,${part.inlineData.data}`;
                    console.log(
                        `Returning base64 image, length: ${base64Image.length}`
                    );
                    return base64Image;
                }
            }
        }

        // No image found in response
        console.error("No inlineData image found in Gemini response");
        throw new Error("Gemini API did not return an image");
    } catch (error) {
        console.error("Gemini API Error:", error);
        throw new Error(`Gemini API Error: ${error.message}`);
    }
};

/**
 * Generates an outfit image using Gemini 3 API with multiple clothing items
 * @param {string} personImage - Base64 encoded image of the person
 * @param {Array<{image: string, category: string}>} clothingItems - Array of clothing items with base64 images and categories
 * @param {string} [resolution='2K'] - Resolution for generated image (default: '2K')
 * @returns {Promise<string>} Generated outfit image as base64 data URL
 */
export const generateOutfitImageGemini3 = async (
    personImage,
    clothingItems,
    resolution = "2K"
) => {
    if (!process.env.GOOGLE_API_KEY) {
        throw new Error("GOOGLE_API_KEY not set");
    }

    console.log("Starting generateOutfitImageGemini3");
    const genAI = new GoogleGenAI({ apiKey: process.env.GOOGLE_API_KEY });

    // Clean base64 data prefix from person image
    const cleanPersonImage = personImage.replace(
        /^data:image\/[^;]+;base64,/,
        ""
    );

    try {
        // Build the prompt describing which items to wear
        const itemDescriptions = clothingItems
            .map((item, index) => {
                return `the ${item.category} from picture ${index + 2}`;
            })
            .join(", ");

        const prompt = `Make the person in picture 1 wear ${itemDescriptions}. Create a realistic image showing the person wearing all these clothing items together.`;

        // Build contents array starting with the prompt and person image
        const contents = [
            { text: prompt },
            {
                inlineData: {
                    mimeType: "image/jpeg",
                    data: cleanPersonImage,
                },
            },
        ];

        // Add each clothing item image
        for (const item of clothingItems) {
            const cleanItemImage = item.image.replace(
                /^data:image\/[^;]+;base64,/,
                ""
            );
            contents.push({
                inlineData: {
                    mimeType: "image/jpeg",
                    data: cleanItemImage,
                },
            });
        }

        console.log(
            `Starting Gemini 3 API call with ${clothingItems.length} clothing items`
        );
        const response = await genAI.models.generateContent({
            model: "gemini-3-pro-image-preview",
            contents: contents,
            config: {
                responseModalities: ["TEXT", "IMAGE"],
                imageConfig: {
                    imageSize: resolution,
                },
            },
        });

        console.log("Gemini 3 API response received");

        // Extract image from response parts
        if (response.candidates && response.candidates[0]?.content?.parts) {
            const parts = response.candidates[0].content.parts;
            console.log(`Response has ${parts.length} parts`);

            for (const part of parts) {
                if (part.text) {
                    console.log(`Response text: ${part.text}`);
                }
                if (part.inlineData) {
                    console.log(
                        `Found inlineData with mimeType: ${part.inlineData.mimeType}`
                    );
                    // Return base64 image with data URL prefix
                    const base64Image = `data:${part.inlineData.mimeType};base64,${part.inlineData.data}`;
                    console.log(
                        `Returning base64 image, length: ${base64Image.length}`
                    );
                    return base64Image;
                }
            }
        }

        // No image found in response
        console.error("No inlineData image found in Gemini 3 response");
        throw new Error("Gemini 3 API did not return an image");
    } catch (error) {
        console.error("Gemini 3 API Error:", error);
        throw new Error(`Gemini 3 API Error: ${error.message}`);
    }
};
