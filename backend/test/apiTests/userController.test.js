import request from "supertest";
import mongoose from "mongoose";
import bcrypt from "bcrypt";
import app from "../../server.js";
import User from "../../src/models/userSchema.js";
import ClothingItem from "../../src/models/clothingSchema.js";
import { generateOutfitImageGemini3 } from "../../src/services/geminiService.js";

// Mock mongoose
jest.mock("mongoose", () => ({
    ...jest.requireActual("mongoose"),
    Types: {
        ObjectId: {
            isValid: jest.fn(),
        },
    },
}));

// Mock the User model
jest.mock("../../src/models/userSchema.js");

// Mock the ClothingItem model
jest.mock("../../src/models/clothingSchema.js");

// Mock bcrypt
jest.mock("bcrypt");

// Mock gemini service
jest.mock("../../src/services/geminiService.js");

describe("User API", () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    describe("GET /api/user/:id", () => {
        test("returns 200 status on success", async () => {
            const mockUserId = "507f1f77bcf86cd799439011";
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);
            User.findById.mockResolvedValue({
                _id: mockUserId,
                name: "Tester",
                email: "tester@example.com",
                password: "hashedPassword123",
            });

            const res = await request(app).get(`/api/user/${mockUserId}`);
            expect(res.statusCode).toBe(200);
        });

        test("returns 400 for invalid id", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(false);

            const res = await request(app).get(`/api/user/fakeIdlalala`);
            expect(res.statusCode).toBe(400);
        });

        test("returns 404 when user not found", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);
            User.findById.mockResolvedValue(null);

            const res = await request(app).get(
                `/api/user/68febf955e6a41add2c48460`
            );
            expect(res.statusCode).toBe(404);
        });
    });

    describe("DELETE /api/user/:id", () => {
        test("returns 200 status on success", async () => {
            const mockUserId = "507f1f77bcf86cd799439011";
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);
            User.findByIdAndDelete.mockResolvedValue({
                _id: mockUserId,
                name: "Tester",
                email: "tester@example.com",
            });

            const res = await request(app).delete(`/api/user/${mockUserId}`);
            expect(res.statusCode).toBe(200);
        });

        test("returns 404 when user does not exist", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);
            User.findByIdAndDelete.mockResolvedValue(null);

            const res = await request(app).delete(
                `/api/user/507f1f77bcf86cd799439011`
            );
            expect(res.statusCode).toBe(404);
        });

        test("returns 400 for invalid id", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(false);

            const res = await request(app).delete(`/api/user/fakeId`);
            expect(res.statusCode).toBe(400);
        });
    });

    // Testing register endpoint
    describe("POST /api/user/register", () => {
        test("returns 201 and user data with ID on successful registration", async () => {
            User.findOne.mockResolvedValue(null);
            bcrypt.hash.mockResolvedValue("hashedPassword123");

            const mockUser = {
                _id: "507f1f77bcf86cd799439011",
                name: "New User",
                email: "newuser@example.com",
                password: "hashedPassword123",
                createdAt: new Date("2025-01-01T00:00:00.000Z"),
            };

            User.create.mockResolvedValue(mockUser);

            const res = await request(app).post("/api/user/register").send({
                name: "New User",
                email: "newuser@example.com",
                password: "validPassword123",
            });

            expect(res.statusCode).toBe(201);
            expect(res.body).toHaveProperty(
                "message",
                "User successfully created!"
            );
            expect(res.body).toHaveProperty("user");
            expect(res.body.user).toHaveProperty(
                "id",
                "507f1f77bcf86cd799439011"
            );
            expect(res.body.user).toHaveProperty("name", "New User");
            expect(res.body.user).toHaveProperty(
                "email",
                "newuser@example.com"
            );
            expect(res.body.user).toHaveProperty("createdAt");
            expect(res.body.user).not.toHaveProperty("password");

            // Verify bcrypt.hash was called
            expect(bcrypt.hash).toHaveBeenCalledWith("validPassword123", 10);
        });

        test("returns 400 when email already exists", async () => {
            User.findOne.mockResolvedValue({
                _id: "existing-id",
                email: "existing@example.com",
            });

            const res = await request(app).post("/api/user/register").send({
                name: "Duplicate",
                email: "existing@example.com",
                password: "validPassword123",
            });

            expect(res.statusCode).toBe(400);
            expect(res.body.message).toContain("Email already in use");
        });

        test("returns 400 when password is invalid", async () => {
            const res = await request(app).post("/api/user/register").send({
                name: "Test",
                email: "test@example.com",
                password: "bad",
            });

            expect(res.statusCode).toBe(400);
            expect(res.body.message).toContain("Password not valid");
        });

        test("returns 400 when email is invalid", async () => {
            const res = await request(app).post("/api/user/register").send({
                name: "Test",
                email: "invalidemail",
                password: "validPassword123",
            });

            expect(res.statusCode).toBe(400);
            expect(res.body.message).toContain("Email is not valid");
        });

        test("returns 400 when required fields are missing", async () => {
            const res = await request(app).post("/api/user/register").send({
                name: "Test",
            });

            expect(res.statusCode).toBe(400);
            expect(res.body.message).toContain(
                "Username, email, and password required"
            );
        });
    });

    // Testing login endpoint
    describe("POST /api/user/login", () => {
        test("returns 200 and user data with ID on successful login", async () => {
            const mockUser = {
                _id: "507f1f77bcf86cd799439011",
                name: "Login Test",
                email: "logintest@example.com",
                password: "hashedPassword123",
                createdAt: new Date("2025-01-01T00:00:00.000Z"),
            };

            User.findOne.mockResolvedValue(mockUser);
            bcrypt.compare.mockResolvedValue(true);

            const res = await request(app).post("/api/user/login").send({
                email: "logintest@example.com",
                password: "myPassword123",
            });

            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty("message", "Login successful");
            expect(res.body).toHaveProperty("user");
            expect(res.body.user).toHaveProperty(
                "id",
                "507f1f77bcf86cd799439011"
            );
            expect(res.body.user).toHaveProperty("name", "Login Test");
            expect(res.body.user).toHaveProperty(
                "email",
                "logintest@example.com"
            );
            expect(res.body.user).toHaveProperty("createdAt");
            expect(res.body.user).not.toHaveProperty("password");

            // Verify bcrypt.compare was called
            expect(bcrypt.compare).toHaveBeenCalledWith(
                "myPassword123",
                "hashedPassword123"
            );
        });

        test("returns 401 when email does not exist", async () => {
            User.findOne.mockResolvedValue(null);

            const res = await request(app).post("/api/user/login").send({
                email: "nonexistent@example.com",
                password: "somePassword123",
            });

            expect(res.statusCode).toBe(401);
            expect(res.body.message).toContain("Invalid email or password");
        });

        test("returns 401 when password is incorrect", async () => {
            const mockUser = {
                _id: "507f1f77bcf86cd799439011",
                name: "Test User",
                email: "test@example.com",
                password: "hashedPassword123",
            };

            User.findOne.mockResolvedValue(mockUser);
            bcrypt.compare.mockResolvedValue(false);

            const res = await request(app).post("/api/user/login").send({
                email: "test@example.com",
                password: "wrongPassword",
            });

            expect(res.statusCode).toBe(401);
            expect(res.body.message).toContain("Invalid email or password");
        });

        test("returns 400 when email is missing", async () => {
            const res = await request(app).post("/api/user/login").send({
                password: "somePassword123",
            });

            expect(res.statusCode).toBe(400);
            expect(res.body.message).toContain(
                "Email and password are required"
            );
        });

        test("returns 400 when password is missing", async () => {
            const res = await request(app).post("/api/user/login").send({
                email: "test@example.com",
            });

            expect(res.statusCode).toBe(400);
            expect(res.body.message).toContain(
                "Email and password are required"
            );
        });

        test("returns 400 when email format is invalid", async () => {
            const res = await request(app).post("/api/user/login").send({
                email: "invalidemail",
                password: "somePassword123",
            });

            expect(res.statusCode).toBe(400);
            expect(res.body.message).toContain("Email is not valid");
        });
    });

    // Testing updateOutfit endpoint
    describe("PATCH /api/user/:userId/:outfitNumber/:category/:itemId", () => {
        const validUserId = "507f1f77bcf86cd799439011";
        const validItemId = "507f1f77bcf86cd799439012";

        test("returns 200 on successful outfit update", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const mockUser = {
                _id: validUserId,
                name: "Test User",
                email: "test@example.com",
                outfit1: {},
                outfit2: {},
                outfit3: {},
                markModified: jest.fn(),
                save: jest.fn().mockResolvedValue(true),
            };

            User.findById.mockResolvedValue(mockUser);

            const res = await request(app).patch(
                `/api/user/${validUserId}/1/tops/${validItemId}`
            );

            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty(
                "message",
                "Outfit updated successfully"
            );
            expect(res.body).toHaveProperty("outfit");
            expect(mockUser.markModified).toHaveBeenCalledWith("outfit1");
            expect(mockUser.save).toHaveBeenCalled();
        });

        test("returns 400 for invalid user ID", async () => {
            mongoose.Types.ObjectId.isValid.mockImplementation(
                (id) => id !== "invalidUserId"
            );

            const res = await request(app).patch(
                `/api/user/invalidUserId/1/tops/${validItemId}`
            );

            expect(res.statusCode).toBe(400);
            expect(res.body).toHaveProperty("message", "Validation failed");
            expect(res.body.errors).toContain("Invalid user ID");
        });

        test("returns 400 for invalid outfit number", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const res = await request(app).patch(
                `/api/user/${validUserId}/5/tops/${validItemId}`
            );

            expect(res.statusCode).toBe(400);
            expect(res.body).toHaveProperty("message", "Validation failed");
            expect(res.body.errors).toContain(
                "Outfit number must be 1, 2, or 3"
            );
        });

        test("returns 400 for invalid category", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const res = await request(app).patch(
                `/api/user/${validUserId}/1/invalidCategory/${validItemId}`
            );

            expect(res.statusCode).toBe(400);
            expect(res.body).toHaveProperty("message", "Validation failed");
            expect(res.body.errors).toContain("Invalid category");
        });

        test("returns 400 for invalid item ID", async () => {
            mongoose.Types.ObjectId.isValid.mockImplementation(
                (id) => id !== "invalidItemId"
            );

            const res = await request(app).patch(
                `/api/user/${validUserId}/1/tops/invalidItemId`
            );

            expect(res.statusCode).toBe(400);
            expect(res.body).toHaveProperty("message", "Validation failed");
            expect(res.body.errors).toContain("Invalid item ID");
        });

        test("returns 400 with multiple validation errors", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(false);

            const res = await request(app).patch(
                `/api/user/badId/7/badCategory/badItemId`
            );

            expect(res.statusCode).toBe(400);
            expect(res.body).toHaveProperty("message", "Validation failed");
            expect(res.body.errors).toContain("Invalid user ID");
            expect(res.body.errors).toContain(
                "Outfit number must be 1, 2, or 3"
            );
            expect(res.body.errors).toContain("Invalid category");
            expect(res.body.errors).toContain("Invalid item ID");
        });

        test("returns 404 when user not found", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);
            User.findById.mockResolvedValue(null);

            const res = await request(app).patch(
                `/api/user/${validUserId}/1/tops/${validItemId}`
            );

            expect(res.statusCode).toBe(404);
            expect(res.body).toHaveProperty("message", "User not found");
        });

        test("updates outfit2 successfully", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const mockUser = {
                _id: validUserId,
                outfit1: {},
                outfit2: {},
                outfit3: {},
                markModified: jest.fn(),
                save: jest.fn().mockResolvedValue(true),
            };

            User.findById.mockResolvedValue(mockUser);

            const res = await request(app).patch(
                `/api/user/${validUserId}/2/bottoms/${validItemId}`
            );

            expect(res.statusCode).toBe(200);
            expect(mockUser.markModified).toHaveBeenCalledWith("outfit2");
        });

        test("updates outfit3 successfully", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const mockUser = {
                _id: validUserId,
                outfit1: {},
                outfit2: {},
                outfit3: {},
                markModified: jest.fn(),
                save: jest.fn().mockResolvedValue(true),
            };

            User.findById.mockResolvedValue(mockUser);

            const res = await request(app).patch(
                `/api/user/${validUserId}/3/shoes/${validItemId}`
            );

            expect(res.statusCode).toBe(200);
            expect(mockUser.markModified).toHaveBeenCalledWith("outfit3");
        });

        test("updates all valid categories", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const categories = [
                "tops",
                "bottoms",
                "shoes",
                "outerwear",
                "accessories",
            ];

            for (const category of categories) {
                const mockUser = {
                    _id: validUserId,
                    outfit1: {},
                    outfit2: {},
                    outfit3: {},
                    markModified: jest.fn(),
                    save: jest.fn().mockResolvedValue(true),
                };

                User.findById.mockResolvedValue(mockUser);

                const res = await request(app).patch(
                    `/api/user/${validUserId}/1/${category}/${validItemId}`
                );

                expect(res.statusCode).toBe(200);
            }
        });

        test("initializes outfit object if it doesn't exist", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const mockUser = {
                _id: validUserId,
                outfit1: null,
                outfit2: {},
                outfit3: {},
                markModified: jest.fn(),
                save: jest.fn().mockResolvedValue(true),
            };

            User.findById.mockResolvedValue(mockUser);

            const res = await request(app).patch(
                `/api/user/${validUserId}/1/tops/${validItemId}`
            );

            expect(res.statusCode).toBe(200);
            expect(mockUser.outfit1).toEqual({ tops: validItemId });
        });

        test("returns 500 on server error", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);
            User.findById.mockRejectedValue(new Error("Database error"));

            const res = await request(app).patch(
                `/api/user/${validUserId}/1/tops/${validItemId}`
            );

            expect(res.statusCode).toBe(500);
            expect(res.body).toHaveProperty(
                "message",
                "Failed to update outfit"
            );
        });
    });

    // Testing generateOutfit endpoint
    describe("POST /api/user/:userId/generate-outfit/:outfitNumber", () => {
        const validUserId = "507f1f77bcf86cd799439011";
        const validItemId1 = "507f1f77bcf86cd799439012";
        const validItemId2 = "507f1f77bcf86cd799439013";
        const validPicture = "data:image/jpeg;base64,/9j/4AAQSkZJRg==";

        test("returns 200 on successful outfit generation", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const mockUser = {
                _id: validUserId,
                outfit1: {
                    tops: validItemId1,
                    bottoms: validItemId2,
                },
            };

            const mockClothingItems = [
                {
                    _id: validItemId1,
                    name: "Blue Shirt",
                    category: "tops",
                    image_data: "data:image/jpeg;base64,shirt123",
                },
                {
                    _id: validItemId2,
                    name: "Black Jeans",
                    category: "bottoms",
                    image_data: "data:image/jpeg;base64,jeans456",
                },
            ];

            User.findById.mockResolvedValue(mockUser);
            ClothingItem.find.mockResolvedValue(mockClothingItems);
            generateOutfitImageGemini3.mockResolvedValue(
                "data:image/png;base64,mockGeneratedImage"
            );

            const res = await request(app)
                .post(`/api/user/${validUserId}/generate-outfit/1`)
                .send({ picture: validPicture });

            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty(
                "message",
                "Outfit generated successfully"
            );
            expect(res.body).toHaveProperty("generatedImage");
            expect(generateOutfitImageGemini3).toHaveBeenCalledWith(
                validPicture,
                [
                    {
                        image: "data:image/jpeg;base64,shirt123",
                        category: "tops",
                    },
                    {
                        image: "data:image/jpeg;base64,jeans456",
                        category: "bottoms",
                    },
                ]
            );
        });

        test("returns 400 for invalid user ID", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(false);

            const res = await request(app)
                .post(`/api/user/invalidId/generate-outfit/1`)
                .send({ picture: validPicture });

            expect(res.statusCode).toBe(400);
            expect(res.body).toHaveProperty("message", "Validation failed");
            expect(res.body.errors).toContain("Invalid user ID");
        });

        test("returns 400 for invalid outfit number", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const res = await request(app)
                .post(`/api/user/${validUserId}/generate-outfit/5`)
                .send({ picture: validPicture });

            expect(res.statusCode).toBe(400);
            expect(res.body).toHaveProperty("message", "Validation failed");
            expect(res.body.errors).toContain(
                "Outfit number must be 1, 2, or 3"
            );
        });

        test("returns 400 for missing picture", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const res = await request(app)
                .post(`/api/user/${validUserId}/generate-outfit/1`)
                .send({});

            expect(res.statusCode).toBe(400);
            expect(res.body).toHaveProperty("message", "Validation failed");
            expect(res.body.errors).toContain(
                "Picture is required and must be a string"
            );
        });

        test("returns 400 for invalid picture format", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const res = await request(app)
                .post(`/api/user/${validUserId}/generate-outfit/1`)
                .send({ picture: "not-a-valid-image" });

            expect(res.statusCode).toBe(400);
            expect(res.body).toHaveProperty("message", "Validation failed");
            expect(res.body.errors).toContain(
                "Picture must be a valid base64 image data URL"
            );
        });

        test("returns 404 when user not found", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);
            User.findById.mockResolvedValue(null);

            const res = await request(app)
                .post(`/api/user/${validUserId}/generate-outfit/1`)
                .send({ picture: validPicture });

            expect(res.statusCode).toBe(404);
            expect(res.body).toHaveProperty("message", "User not found");
        });

        test("returns 400 when outfit is empty", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const mockUser = {
                _id: validUserId,
                outfit1: {},
            };

            User.findById.mockResolvedValue(mockUser);

            const res = await request(app)
                .post(`/api/user/${validUserId}/generate-outfit/1`)
                .send({ picture: validPicture });

            expect(res.statusCode).toBe(400);
            expect(res.body).toHaveProperty("message", "Outfit is empty");
        });

        test("generates outfit with clothing items", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const mockUser = {
                _id: validUserId,
                outfit1: {
                    tops: validItemId1,
                },
            };

            const mockClothingItems = [
                {
                    _id: validItemId1,
                    name: "Blue Shirt",
                    category: "tops",
                    image_data: "data:image/jpeg;base64,shirt123",
                },
            ];

            User.findById.mockResolvedValue(mockUser);
            ClothingItem.find.mockResolvedValue(mockClothingItems);
            generateOutfitImageGemini3.mockResolvedValue(
                "data:image/png;base64,mockGeneratedImage"
            );

            const res = await request(app)
                .post(`/api/user/${validUserId}/generate-outfit/1`)
                .send({ picture: validPicture });

            expect(res.statusCode).toBe(200);
            expect(generateOutfitImageGemini3).toHaveBeenCalledWith(
                validPicture,
                [{ image: "data:image/jpeg;base64,shirt123", category: "tops" }]
            );
        });

        test("works with outfit2 and outfit3", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);

            const mockUser = {
                _id: validUserId,
                outfit2: { tops: validItemId1 },
                outfit3: { bottoms: validItemId2 },
            };

            const mockClothingItems = [
                {
                    _id: validItemId1,
                    category: "tops",
                    image_data: "data:image/jpeg;base64,item1",
                },
            ];

            User.findById.mockResolvedValue(mockUser);
            ClothingItem.find.mockResolvedValue(mockClothingItems);
            generateOutfitImageGemini3.mockResolvedValue(
                "data:image/png;base64,mock"
            );

            const res2 = await request(app)
                .post(`/api/user/${validUserId}/generate-outfit/2`)
                .send({ picture: validPicture });

            expect(res2.statusCode).toBe(200);

            const res3 = await request(app)
                .post(`/api/user/${validUserId}/generate-outfit/3`)
                .send({ picture: validPicture });

            expect(res3.statusCode).toBe(200);
        });

        test("returns 500 on server error", async () => {
            mongoose.Types.ObjectId.isValid.mockReturnValue(true);
            User.findById.mockRejectedValue(new Error("Database error"));

            const res = await request(app)
                .post(`/api/user/${validUserId}/generate-outfit/1`)
                .send({ picture: validPicture });

            expect(res.statusCode).toBe(500);
            expect(res.body).toHaveProperty(
                "message",
                "Failed to generate outfit"
            );
        });
    });
});
