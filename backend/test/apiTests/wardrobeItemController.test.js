import request from "supertest";
import mongoose from "mongoose";
import app from "../../server.js";
import WardrobeItem from "../../src/models/clothingSchema.js";
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

// Mock the User/Clothing model
jest.mock("../../src/models/userSchema.js");
jest.mock("../../src/models/clothingSchema.js");

jest.mock("bcrypt");

describe("Wardrobe API", () => {
    beforeEach(async () => {
        jest.clearAllMocks();
    });

    test("GET /api/wardrobe returns 201 (ID only)", async () => {
        const mockUserId = "507f1f77bcf86cd799439011";
        mongoose.Types.ObjectId.isValid.mockReturnValue(true);
        User.findById.mockResolvedValue({
            _id: mockUserId,
            name: "Tester",
            email: "tester@example.com",
            password: "hashedPassword123",
        });
        WardrobeItem.find.mockReturnValue({
            sort: jest.fn().mockResolvedValue([]),
        });
        const res = await request(app).get(
            `/api/wardrobe/?userId=${mockUserId}`
        );
        expect(res.statusCode).toBe(201);
    });

    test("GET /api/wardrobe returns 201 (ID + Category)", async () => {
        const mockUserId = "507f1f77bcf86cd799439011";
        mongoose.Types.ObjectId.isValid.mockReturnValue(true);
        User.findById.mockResolvedValue({
            _id: mockUserId,
            name: "Tester",
            email: "tester@example.com",
            password: "hashedPassword123",
        });
        WardrobeItem.find.mockReturnValue({
            sort: jest.fn().mockResolvedValue([]),
        });
        const res = await request(app).get(
            `/api/wardrobe/?userId=${mockUserId}&category=tops`
        );
        expect(res.statusCode).toBe(201);
    });

    test("GET /api/wardrobe returns 400 (Invalid id)", async () => {
        const mockUserId = "fakeId";
        mongoose.Types.ObjectId.isValid.mockReturnValue(false);
        const res = await request(app).get(
            `/api/wardrobe/?userId=${mockUserId}`
        );
        expect(res.statusCode).toBe(400);
    });

    // // test("POST /api/wardrobe returns 201 (Success)", async () => {
    // //     const existingId = testUser1._id;
    // //     const res = await request(app).post(`/api/wardrobe/`)
    // //         .send({
    // //             userId: existingId,
    // //             category: "tops",
    // //             name: "Zara shirt",
    // //             price: 50,
    // //             brand: "Zara",
    // //             size: "M",
    // //             color: "Blue",
    // //             description: "",
    // //             image_data: "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"
    // //         });
    // //     expect(res.statusCode).toBe(201);
    // // });

    test("POST /api/wardrobe returns 400 (Invalid ID)", async () => {
        const res = await request(app).post(`/api/wardrobe/`).send({
            userId: "fake Id stuff",
            category: "tops",
            name: "Zara shirt",
            price: 50,
            brand: "Zara",
            description: "",
        });
        expect(res.statusCode).toBe(400);
        expect(res.body.message).toBe("User id not valid. Try again");
    });

    test("DELETE /api/wardrobe/:id returns 200 (Success)", async () => {
        const mockUserId = "507f1f77bcf86cd799439011";
        const mockItemId = "507f1f77bcf86cd799439022";

        mongoose.Types.ObjectId.isValid.mockReturnValue(true);

        WardrobeItem.findByIdAndDelete.mockResolvedValue({
            _id: mockItemId,
            userId: mockUserId,
            name: "Zara shirt",
            category: "tops",
            price: 50,
            brand: "Zara",
            size: "M",
            color: "Blue",
        });

        mongoose.Types.ObjectId.isValid.mockReturnValue(true);

        const res = await request(app).delete(`/api/wardrobe/${mockItemId}`);

        expect(res.statusCode).toBe(200);
        expect(res.body.success).toBe(true);
        expect(WardrobeItem.findByIdAndDelete).toHaveBeenCalledWith(mockItemId);
    });

    test("DELETE /api/wardrobe/:id returns 400 (Not Found)", async () => {
        const mockItemId = "507f1f77bcf86cd799439022";

        mongoose.Types.ObjectId.isValid.mockReturnValue(true);

        WardrobeItem.findByIdAndDelete.mockResolvedValue(null);

        const res = await request(app).delete(`/api/wardrobe/${mockItemId}`);

        expect(res.statusCode).toBe(400);
        expect(res.body.message).toBe(
            "Clothing item is not found given the Id"
        );
        expect(WardrobeItem.findByIdAndDelete).toHaveBeenCalledWith(mockItemId);
    });

    test("PUT /api/wardrobe/:id returns 200 (Success)", async () => {
        const mockUserId = "507f1f77bcf86cd799439011";
        const mockItemId = "507f1f77bcf86cd799439022";

        mongoose.Types.ObjectId.isValid.mockReturnValue(true);

        WardrobeItem.findByIdAndUpdate.mockResolvedValue({
            _id: mockItemId,
            userId: mockUserId,
            category: "bottoms",
            name: "Zara pants",
            price: 50,
            brand: "Zara",
            size: "M",
            color: "Blue",
            description: "",
            image_data: "base64data",
        });

        const res = await request(app).put(`/api/wardrobe/${mockItemId}`).send({
            category: "bottoms",
            name: "Zara pants",
        });

        expect(res.statusCode).toBe(200);
        expect(WardrobeItem.findByIdAndUpdate).toHaveBeenCalledWith(
            mockItemId,
            {
                $set: expect.objectContaining({
                    category: "bottoms",
                    name: "Zara pants",
                }),
            },
            { new: true }
        );
    });
});
