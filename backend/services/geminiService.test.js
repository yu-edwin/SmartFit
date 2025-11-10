import { jest } from "@jest/globals";

// Create a mock module before importing
const mockGenerateContent = jest.fn();
const mockGenAI = {
    models: {
        generateContent: mockGenerateContent,
    },
};

// Mock the Google Generative AI library
jest.unstable_mockModule("@google/genai", () => {
    return {
        GoogleGenAI: jest.fn(() => mockGenAI),
    };
});

const { analyzeClothingImage } = await import("./geminiService.js");
const { GoogleGenAI } = await import("@google/genai");

describe("geminiService", () => {
    beforeEach(() => {
        // Clear all mocks before each test
        jest.clearAllMocks();
        mockGenerateContent.mockClear();
        GoogleGenAI.mockClear();

        // Reset environment
        delete process.env.GOOGLE_API_KEY;
    });

    describe("analyzeClothingImage", () => {
        it("should successfully analyze a clothing image with base64 data", async () => {
            // Arrange
            const base64Data =
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk";
            const expectedDescription = "A blue cotton t-shirt";
            mockGenerateContent.mockResolvedValue({
                text: expectedDescription,
            });
            process.env.GOOGLE_API_KEY = "test-api-key";

            // Act
            const result = await analyzeClothingImage(base64Data);

            // Assert
            expect(result).toBe(expectedDescription);
            expect(GoogleGenAI).toHaveBeenCalledWith({
                apiKey: "test-api-key",
            });
            expect(mockGenerateContent).toHaveBeenCalledWith({
                model: "gemini-2.0-flash",
                contents: [
                    {
                        inlineData: {
                            mimeType: "image/jpeg",
                            data: base64Data,
                        },
                    },
                    { text: "describe the clothes on this image" },
                ],
            });
        });

        it("should clean base64 data with data URI prefix", async () => {
            // Arrange
            const base64WithPrefix =
                "data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk";
            const cleanBase64 =
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk";
            const expectedDescription = "A red dress";
            mockGenerateContent.mockResolvedValue({
                text: expectedDescription,
            });
            process.env.GOOGLE_API_KEY = "test-api-key";

            // Act
            const result = await analyzeClothingImage(base64WithPrefix);

            // Assert
            expect(result).toBe(expectedDescription);
            expect(mockGenerateContent).toHaveBeenCalledWith({
                model: "gemini-2.0-flash",
                contents: [
                    {
                        inlineData: {
                            mimeType: "image/jpeg",
                            data: cleanBase64,
                        },
                    },
                    { text: "describe the clothes on this image" },
                ],
            });
        });

        it("should clean base64 data with different image type prefix", async () => {
            // Arrange
            const base64WithPrefix =
                "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk";
            const cleanBase64 =
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk";
            mockGenerateContent.mockResolvedValue({
                text: "A jacket",
            });
            process.env.GOOGLE_API_KEY = "test-api-key";

            // Act
            await analyzeClothingImage(base64WithPrefix);

            // Assert
            const callArgs = mockGenerateContent.mock.calls[0][0];
            expect(callArgs.contents[0].inlineData.data).toBe(cleanBase64);
        });

        it("should throw an error when GOOGLE_API_KEY is not set", async () => {
            // Arrange
            delete process.env.GOOGLE_API_KEY;
            const base64Data =
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk";

            // Act & Assert
            await expect(analyzeClothingImage(base64Data)).rejects.toThrow(
                "GOOGLE_API_KEY not set"
            );

            // Verify GoogleGenAI was not instantiated
            expect(GoogleGenAI).not.toHaveBeenCalled();
        });

        it("should throw an error when Gemini API fails", async () => {
            // Arrange
            const base64Data =
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk";
            const apiError = new Error("API Rate Limit Exceeded");
            mockGenerateContent.mockRejectedValue(apiError);
            process.env.GOOGLE_API_KEY = "test-api-key";

            // Act & Assert
            await expect(analyzeClothingImage(base64Data)).rejects.toThrow(
                "Gemini API Error: API Rate Limit Exceeded"
            );
        });

        it("should throw an error when Gemini API returns invalid response", async () => {
            // Arrange
            const base64Data =
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk";
            mockGenerateContent.mockRejectedValue(
                new Error("Invalid response format")
            );
            process.env.GOOGLE_API_KEY = "test-api-key";

            // Act & Assert
            await expect(analyzeClothingImage(base64Data)).rejects.toThrow(
                "Gemini API Error: Invalid response format"
            );
        });

        it("should send correct prompt to Gemini API", async () => {
            // Arrange
            const base64Data = "testBase64Data";
            mockGenerateContent.mockResolvedValue({
                text: "Description",
            });
            process.env.GOOGLE_API_KEY = "test-api-key";

            // Act
            await analyzeClothingImage(base64Data);

            // Assert
            const callArgs = mockGenerateContent.mock.calls[0][0];
            expect(callArgs.contents).toEqual(
                expect.arrayContaining([
                    expect.objectContaining({
                        text: "describe the clothes on this image",
                    }),
                ])
            );
        });

        it("should use gemini-2.0-flash model", async () => {
            // Arrange
            const base64Data = "testBase64Data";
            mockGenerateContent.mockResolvedValue({
                text: "Description",
            });
            process.env.GOOGLE_API_KEY = "test-api-key";

            // Act
            await analyzeClothingImage(base64Data);

            // Assert
            const callArgs = mockGenerateContent.mock.calls[0][0];
            expect(callArgs.model).toBe("gemini-2.0-flash");
        });

        it("should handle empty base64 string", async () => {
            // Arrange
            const emptyBase64 = "";
            mockGenerateContent.mockResolvedValue({
                text: "No image provided",
            });
            process.env.GOOGLE_API_KEY = "test-api-key";

            // Act
            const result = await analyzeClothingImage(emptyBase64);

            // Assert
            expect(result).toBe("No image provided");
            expect(mockGenerateContent).toHaveBeenCalled();
        });

        it("should preserve base64 data integrity after cleaning", async () => {
            // Arrange
            const originalData = "ABC123xyz/+=";
            const base64WithPrefix = `data:image/jpeg;base64,${originalData}`;
            mockGenerateContent.mockResolvedValue({
                text: "Description",
            });
            process.env.GOOGLE_API_KEY = "test-api-key";

            // Act
            await analyzeClothingImage(base64WithPrefix);

            // Assert
            const callArgs = mockGenerateContent.mock.calls[0][0];
            expect(callArgs.contents[0].inlineData.data).toBe(originalData);
        });

        it("should always use image/jpeg mimetype", async () => {
            // Arrange
            const base64Data = "testData";
            mockGenerateContent.mockResolvedValue({
                text: "Description",
            });
            process.env.GOOGLE_API_KEY = "test-api-key";

            // Act
            await analyzeClothingImage(base64Data);

            // Assert
            const callArgs = mockGenerateContent.mock.calls[0][0];
            expect(callArgs.contents[0].inlineData.mimeType).toBe("image/jpeg");
        });
    });
});
