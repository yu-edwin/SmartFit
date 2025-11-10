import request from "supertest";
import mongoose from "mongoose";
import bcrypt from "bcrypt";
import app from "../../server.js";
import User from "../../src/models/userSchema.js";

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

// Mock bcrypt
jest.mock("bcrypt");

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
});
