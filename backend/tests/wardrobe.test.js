import request from "supertest";
import mongoose from "mongoose";
import express from "express";
import cors from "cors";
import Wardrobeitem from "../models/clothingSchema.js";
import wardrobeRoutes from "../routes/wardrobeRoutes.js";

const app = express();
app.use(cors());
app.use(express.json({ limit: "50mb" }));
app.use("/api/wardrobe", wardrobeRoutes);

describe("Wardrobe API - Enhanced Item Form Tests", () => {
    let testUserId;
    let testItemId;

    beforeAll(async () => {
        // Use test database
        const testDbUri =
            process.env.MONGODB_TEST_URI ||
            "mongodb://localhost:27017/smartfit-test";
        await mongoose.connect(testDbUri);
        testUserId = new mongoose.Types.ObjectId();
    });

    afterAll(async () => {
        // Clean up test data
        await Wardrobeitem.deleteMany({ userId: testUserId });
        await mongoose.connection.close();
    });

    describe("POST /api/wardrobe - Add Item with New Fields", () => {
        test("Should successfully add item with all required fields (name, color, size)", async () => {
            const newItem = {
                userId: testUserId.toString(),
                name: "Test Nike Shirt",
                category: "tops",
                color: "blue",
                size: "M",
                brand: "Nike",
            };

            const response = await request(app)
                .post("/api/wardrobe")
                .send(newItem)
                .expect(201);

            expect(response.body.success).toBe(true);
            expect(response.body.data.name).toBe("Test Nike Shirt");
            expect(response.body.data.color).toBe("blue");
            expect(response.body.data.size).toBe("M");
            testItemId = response.body.data._id;
            expect(testItemId).toBe(response.body.data._id);
        });

        test("Should fail when color field is missing (required field)", async () => {
            const itemWithoutColor = {
                userId: testUserId.toString(),
                name: "Test Item",
                category: "tops",
                size: "L",
            };

            const response = await request(app)
                .post("/api/wardrobe")
                .send(itemWithoutColor)
                .expect(500);

            expect(response.body.success).toBe(false);
        });

        test("Should fail when size field is missing (required field)", async () => {
            const itemWithoutSize = {
                userId: testUserId.toString(),
                name: "Test Item",
                category: "tops",
                color: "red",
            };

            const response = await request(app)
                .post("/api/wardrobe")
                .send(itemWithoutSize)
                .expect(500);

            expect(response.body.success).toBe(false);
        });

        test("Should automatically convert size to uppercase", async () => {
            const itemWithLowercaseSize = {
                userId: testUserId.toString(),
                name: "Lowercase Size Test",
                category: "tops",
                color: "green",
                size: "xl",
            };

            const response = await request(app)
                .post("/api/wardrobe")
                .send(itemWithLowercaseSize)
                .expect(201);

            expect(response.body.data.size).toBe("XL");
        });

        test("Should successfully add item with optional price field", async () => {
            const itemWithPrice = {
                userId: testUserId.toString(),
                name: "Expensive Shirt",
                category: "tops",
                color: "black",
                size: "L",
                price: 99.99,
            };

            const response = await request(app)
                .post("/api/wardrobe")
                .send(itemWithPrice)
                .expect(201);

            expect(response.body.data.price).toBe(99.99);
        });

        test("Should successfully add item with optional material field", async () => {
            const itemWithMaterial = {
                userId: testUserId.toString(),
                name: "Cotton Shirt",
                category: "tops",
                color: "white",
                size: "M",
                material: "Cotton",
            };

            const response = await request(app)
                .post("/api/wardrobe")
                .send(itemWithMaterial)
                .expect(201);

            expect(response.body.data.material).toBe("Cotton");
        });

        test("Should successfully add item with optional product URL field", async () => {
            const itemWithUrl = {
                userId: testUserId.toString(),
                name: "Online Shirt",
                category: "tops",
                color: "gray",
                size: "S",
                item_url: "https://example.com/shirt",
            };

            const response = await request(app)
                .post("/api/wardrobe")
                .send(itemWithUrl)
                .expect(201);

            expect(response.body.data.item_url).toBe(
                "https://example.com/shirt"
            );
        });

        test("Should successfully add item with all fields (required + optional)", async () => {
            const completeItem = {
                userId: testUserId.toString(),
                name: "Complete Item",
                category: "shoes",
                color: "brown",
                size: "L",
                brand: "Adidas",
                price: 149.99,
                material: "Leather",
                item_url: "https://adidas.com/shoes",
            };

            const response = await request(app)
                .post("/api/wardrobe")
                .send(completeItem)
                .expect(201);

            expect(response.body.data.name).toBe("Complete Item");
            expect(response.body.data.color).toBe("brown");
            expect(response.body.data.size).toBe("L");
            expect(response.body.data.brand).toBe("Adidas");
            expect(response.body.data.price).toBe(149.99);
            expect(response.body.data.material).toBe("Leather");
            expect(response.body.data.item_url).toBe(
                "https://adidas.com/shoes"
            );
        });

        test("Should reject negative price values", async () => {
            const itemWithNegativePrice = {
                userId: testUserId.toString(),
                name: "Negative Price Item",
                category: "tops",
                color: "blue",
                size: "M",
                price: -10,
            };

            const response = await request(app)
                .post("/api/wardrobe")
                .send(itemWithNegativePrice)
                .expect(500);

            expect(response.body.success).toBe(false);
        });
    });

    describe("GET /api/wardrobe - Retrieve Items", () => {
        test("Should retrieve items with new fields displayed", async () => {
            const response = await request(app)
                .get("/api/wardrobe")
                .query({ userId: testUserId.toString() })
                .expect(200);

            expect(response.body).toHaveProperty("data");
            expect(Array.isArray(response.body.data)).toBe(true);

            if (response.body.data.length > 0) {
                const item = response.body.data[0];
                expect(item).toHaveProperty("color");
                expect(item).toHaveProperty("size");
                expect(item).toHaveProperty("price");
            }
        });
    });

    describe("Size Field Validation", () => {
        test("Should accept valid size: XS", async () => {
            const item = {
                userId: testUserId.toString(),
                name: "XS Test",
                category: "tops",
                color: "red",
                size: "XS",
            };

            const response = await request(app)
                .post("/api/wardrobe")
                .send(item)
                .expect(201);

            expect(response.body.data.size).toBe("XS");
        });

        test("Should accept valid size: XXL", async () => {
            const item = {
                userId: testUserId.toString(),
                name: "XXL Test",
                category: "tops",
                color: "blue",
                size: "XXL",
            };

            const response = await request(app)
                .post("/api/wardrobe")
                .send(item)
                .expect(201);

            expect(response.body.data.size).toBe("XXL");
        });
    });
});
