import {
    scrapeProductInfo,
    isValidProductUrl,
} from "../services/productScraperService.js";
import mongoose from "mongoose";
import Wardrobeitem from "../models/clothingSchema.js";
import { analyzeClothingImage } from "../services/geminiService.js";

// GET request: Get all items in wardrobe
export const getAllItems = async (req, res) => {
    try {
        const { userId, category } = req.query;

        if (!userId || !mongoose.Types.ObjectId.isValid(userId)) {
            return res.status(400).json({ message: "Require valid userID" });
        }

        let query = {};
        if (userId) query.userId = userId;
        if (category) query.category = category;

        const items = await Wardrobeitem.find(query).sort({ createdAt: -1 });

        res.status(201).json({ data: items });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// POST request: Insert new clothing item in wardrobe
export const createClothingItem = async (req, res) => {
    try {
        let {
            userId,
            category,
            name,
            price,
            brand,
            description,
            image_data,
            color,
            size,
            material,
            item_url,
        } = req.body;

        if (userId && !mongoose.Types.ObjectId.isValid(userId)) {
            return res
                .status(400)
                .json({ message: "User id not valid. Try again" });
        }

        // Calling on gemini service
        if (image_data) {
            description = await analyzeClothingImage(image_data);
        }

        const newItem = await Wardrobeitem.create({
            userId,
            category,
            name,
            price,
            brand,
            description,
            image_data,
            color,
            size,
            material,
            item_url,
        });

        res.status(201).json({ data: newItem });
    } catch (err) {
        console.error("Error:", err);
        res.status(500).json({
            message: `POST REQUEST wardrobeItem FAILED!! \n ${err}`,
        });
    }
};

// DELETE request: Deletes an item in wardrobe based on ID
export const deleteClothingItem = async (req, res) => {
    try {
        const deletedClothingItem = await Wardrobeitem.findByIdAndDelete(
            req.params.id
        );
        if (!deletedClothingItem) {
            return res
                .status(400)
                .json({ message: "Clothing item is not found given the Id" });
        }
        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// PUT request: Updates field(s) of the clothing item object
export const updateClothingItem = async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;
        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({
                message: "You have provided an invalid clothing ID. Try again",
            });
        }

        const updatedItem = await Wardrobeitem.findByIdAndUpdate(
            id,
            { $set: updates },
            { new: true }
        );

        res.status(200).json({
            message: `You have updated clothing item id: ${id}`,
            data: updatedItem,
        });
    } catch (err) {
        res.status(500).json({
            message: `Failed to update clothing item... HERE IS ERROR: ${err}`,
        });
    }
};

export const importFromUrl = async (req, res) => {
    try {
        const { userId, productUrl, size = "M" } = req.body;

        if (!userId || !mongoose.Types.ObjectId.isValid(userId)) {
            return res.status(400).json({
                message: "Valid user ID required",
            });
        }

        if (!productUrl || !isValidProductUrl(productUrl)) {
            return res.status(400).json({
                message: "Valid product URL required",
            });
        }

        const scrapedData = await scrapeProductInfo(productUrl);

        const newItem = await Wardrobeitem.create({
            userId,
            name: scrapedData.name,
            category: scrapedData.category,
            brand: scrapedData.brand || "",
            price: scrapedData.price || 0,
            color: scrapedData.color || "Not specified",
            size: size.toUpperCase(),
            material: scrapedData.material || "",
            item_url: productUrl,
            image_data: scrapedData.image_data,
        });

        res.status(201).json({
            data: newItem,
            scraped: scrapedData.scraped_successfully,
        });
    } catch (error) {
        console.error("Import error:", error);
        res.status(500).json({
            message: `Import failed: ${error.message}`,
        });
    }
};
