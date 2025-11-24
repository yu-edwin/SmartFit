import { analyzeClothingImage, generateOutfitImage } from "../../src/services/geminiService.js";
import { GoogleGenAI } from "@google/genai";

// Mock the GoogleGenAI module
jest.mock("@google/genai");

describe("Gemini Service", () => {
    let mockGenAI;
    let mockGenerateContent;

    beforeEach(() => {
        jest.clearAllMocks();

        // Set up mock API key
        process.env.GOOGLE_API_KEY = "test-api-key";

        // Mock generateContent method
        mockGenerateContent = jest.fn();
        mockGenAI = {
            models: {
                generateContent: mockGenerateContent
            }
        };

        // Mock GoogleGenAI constructor
        GoogleGenAI.mockImplementation(() => mockGenAI);
    });

    afterEach(() => {
        delete process.env.GOOGLE_API_KEY;
    });

    describe("analyzeClothingImage", () => {
        const testBase64 = "data:image/jpeg;base64,/9j/4AAQSkZJRg==";
        const cleanBase64 = "/9j/4AAQSkZJRg==";

        test("successfully analyzes clothing image", async () => {
            const mockDescription = "A blue denim jacket with silver buttons";
            mockGenerateContent.mockResolvedValue({ text: mockDescription });

            const result = await analyzeClothingImage(testBase64);

            expect(result).toBe(mockDescription);
            expect(GoogleGenAI).toHaveBeenCalledWith({ apiKey: "test-api-key" });
            expect(mockGenerateContent).toHaveBeenCalledWith({
                model: "gemini-2.0-flash",
                contents: [
                    {
                        inlineData: {
                            mimeType: "image/jpeg",
                            data: cleanBase64
                        }
                    },
                    { text: "describe the clothes on this image" }
                ]
            });
        });

        test("handles base64 without data prefix", async () => {
            const mockDescription = "A red t-shirt";
            mockGenerateContent.mockResolvedValue({ text: mockDescription });

            const result = await analyzeClothingImage(cleanBase64);

            expect(result).toBe(mockDescription);
            expect(mockGenerateContent).toHaveBeenCalledWith(
                expect.objectContaining({
                    contents: expect.arrayContaining([
                        expect.objectContaining({
                            inlineData: expect.objectContaining({
                                data: cleanBase64
                            })
                        })
                    ])
                })
            );
        });

        test("throws error when GOOGLE_API_KEY is not set", async () => {
            delete process.env.GOOGLE_API_KEY;

            await expect(analyzeClothingImage(testBase64)).rejects.toThrow(
                "GOOGLE_API_KEY not set"
            );
        });

        test("throws error when Gemini API fails", async () => {
            const apiError = new Error("API rate limit exceeded");
            mockGenerateContent.mockRejectedValue(apiError);

            await expect(analyzeClothingImage(testBase64)).rejects.toThrow(
                "Gemini API Error: API rate limit exceeded"
            );
        });

        test("handles different image formats", async () => {
            const pngBase64 = "data:image/png;base64,iVBORw0KGgo=";
            const cleanPng = "iVBORw0KGgo=";
            const mockDescription = "A white shirt";
            mockGenerateContent.mockResolvedValue({ text: mockDescription });

            const result = await analyzeClothingImage(pngBase64);

            expect(result).toBe(mockDescription);
            expect(mockGenerateContent).toHaveBeenCalledWith(
                expect.objectContaining({
                    contents: expect.arrayContaining([
                        expect.objectContaining({
                            inlineData: expect.objectContaining({
                                data: cleanPng
                            })
                        })
                    ])
                })
            );
        });
    });

    describe("generateOutfitImage", () => {
        const testPicture = "data:image/jpeg;base64,/9j/4AAQSkZJRg==";
        const cleanPicture = "/9j/4AAQSkZJRg==";
        const testPrompt = "blue jeans red shirt white sneakers";

        test("successfully generates outfit image", async () => {
            const mockGeneratedImage = "data:image/png;base64,generatedImageData";
            mockGenerateContent.mockResolvedValue({ text: mockGeneratedImage });

            const result = await generateOutfitImage(testPrompt, testPicture);

            expect(result).toBe(mockGeneratedImage);
            expect(GoogleGenAI).toHaveBeenCalledWith({ apiKey: "test-api-key" });
            expect(mockGenerateContent).toHaveBeenCalledWith({
                model: "gemini-2.5-flash-image",
                contents: [
                    {
                        inlineData: {
                            mimeType: "image/jpeg",
                            data: cleanPicture
                        }
                    },
                    {
                        text: `Generate an outfit visualization on this person wearing the following items: ${testPrompt}`
                    }
                ]
            });
        });

        test("handles empty prompt", async () => {
            const mockGeneratedImage = "data:image/png;base64,generated";
            mockGenerateContent.mockResolvedValue({ text: mockGeneratedImage });

            const result = await generateOutfitImage("", testPicture);

            expect(result).toBe(mockGeneratedImage);
            expect(mockGenerateContent).toHaveBeenCalledWith(
                expect.objectContaining({
                    contents: expect.arrayContaining([
                        expect.objectContaining({
                            text: "Generate an outfit visualization on this person wearing the following items: "
                        })
                    ])
                })
            );
        });

        test("cleans base64 data prefix from picture", async () => {
            const mockGeneratedImage = "generated-image";
            mockGenerateContent.mockResolvedValue({ text: mockGeneratedImage });

            await generateOutfitImage(testPrompt, testPicture);

            expect(mockGenerateContent).toHaveBeenCalledWith(
                expect.objectContaining({
                    contents: expect.arrayContaining([
                        expect.objectContaining({
                            inlineData: expect.objectContaining({
                                data: cleanPicture
                            })
                        })
                    ])
                })
            );
        });

        test("throws error when GOOGLE_API_KEY is not set", async () => {
            delete process.env.GOOGLE_API_KEY;

            await expect(generateOutfitImage(testPrompt, testPicture)).rejects.toThrow(
                "GOOGLE_API_KEY not set"
            );
        });

        test("throws error when Gemini API fails", async () => {
            const apiError = new Error("Image generation failed");
            mockGenerateContent.mockRejectedValue(apiError);

            await expect(generateOutfitImage(testPrompt, testPicture)).rejects.toThrow(
                "Gemini API Error: Image generation failed"
            );
        });

        test("uses correct model (gemini-2.5-flash-image)", async () => {
            mockGenerateContent.mockResolvedValue({ text: "generated" });

            await generateOutfitImage(testPrompt, testPicture);

            expect(mockGenerateContent).toHaveBeenCalledWith(
                expect.objectContaining({
                    model: "gemini-2.5-flash-image"
                })
            );
        });

        test("handles complex prompts with multiple items", async () => {
            const complexPrompt = "vintage denim jacket with patches black skinny jeans leather boots with buckles";
            const mockGeneratedImage = "generated-complex-outfit";
            mockGenerateContent.mockResolvedValue({ text: mockGeneratedImage });

            const result = await generateOutfitImage(complexPrompt, testPicture);

            expect(result).toBe(mockGeneratedImage);
            expect(mockGenerateContent).toHaveBeenCalledWith(
                expect.objectContaining({
                    contents: expect.arrayContaining([
                        expect.objectContaining({
                            text: `Generate an outfit visualization on this person wearing the following items: ${complexPrompt}`
                        })
                    ])
                })
            );
        });
    });
});
