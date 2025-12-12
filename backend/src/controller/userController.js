import bcrypt from "bcrypt";
import mongoose from "mongoose";
import User from "../models/userSchema.js";
import ClothingItem from "../models/clothingSchema.js";
import { isValidEmail, isValidPassword } from "../utils/validation.js";
import { generateOutfitImageGemini3 } from "../services/geminiService.js";

// GET request: Gets all info from user.
export const getUserInfo = async (req, res) => {
    try {
        const { id } = req.params;
        // console.log("Trying to fetch user")
        if (!id || !mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({ message: "Provided invalid ID" });
        }

        const user = await User.findById(id);
        if (!user) {
            return res
                .status(404)
                .json({ message: `User not found by ID: ${id}` });
        }
        // console.log("Found user!");
        res.status(200).json({ user });
    } catch (err) {
        console.error(`Cannot fetch user based on ID... Here is error: ${err}`);
        return res
            .status(500)
            .json({ message: "Server Error trying to get USER INFO BY ID" });
    }
};

// POST request: Request to be called when creating a new user
/*
1. Checks valid name, email, and password in req.body
2. Checks if email/password is valid
3. Checks if email already exists
4. Hash password
5. Create User
*/
export const createUserInfo = async (req, res) => {
    try {
        const { name, email, password } = req.body;
        if (!name || !email || !password) {
            return res
                .status(400)
                .json({ message: "Username, email, and password required" });
        }

        if (!isValidEmail(email)) {
            return res
                .status(400)
                .json({ message: "Email is not valid. Try again" });
        }

        if (!isValidPassword(password)) {
            return res
                .status(400)
                .json({ message: "Password not valid. Try again" });
        }
        const locateUser = await User.findOne({ email });

        if (locateUser) {
            return res.status(400).json({
                message: "Email already in use. Please use another email",
            });
        }

        const hashPassword = await bcrypt.hash(password, 10);

        const newUser = await User.create({
            name: name,
            email: email,
            password: hashPassword,
        });
        if (newUser) {
            // Return user data without password
            const userResponse = {
                id: newUser._id,
                name: newUser.name,
                email: newUser.email,
                createdAt: newUser.createdAt,
            };
            console.log("Successfully Created a user!!");
            return res.status(201).json({
                message: "User successfully created!",
                user: userResponse,
            });
        } else {
            return res.status(400).json({ message: "Error creating new user" });
        }
    } catch (err) {
        console.error(`POST Request failed!! Error msg: ${err}`);
        return res
            .status(500)
            .json({ message: "POST request failed. Try again" });
    }
};

// POST request: Login user with email and password
export const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res
                .status(400)
                .json({ message: "Email and password are required" });
        }

        if (!isValidEmail(email)) {
            return res.status(400).json({ message: "Email is not valid" });
        }

        const user = await User.findOne({ email });

        if (!user) {
            return res
                .status(401)
                .json({ message: "Invalid email or password" });
        }

        const isPasswordValid = await bcrypt.compare(password, user.password);

        if (!isPasswordValid) {
            return res
                .status(401)
                .json({ message: "Invalid email or password" });
        }

        // Return user data without password
        const userResponse = {
            id: user._id,
            name: user.name,
            email: user.email,
            createdAt: user.createdAt,
        };

        return res.status(200).json({
            message: "Login successful",
            user: userResponse,
        });
    } catch (err) {
        console.error(`Login failed!! Error: ${err}`);
        return res.status(500).json({ message: "Login failed. Try again" });
    }
};

// DELETE request: Deletes a user based on ID provided
export const deleteUser = async (req, res) => {
    try {
        const { id } = req.params;

        if (!id || !mongoose.Types.ObjectId.isValid(id)) {
            return res
                .status(400)
                .json({ message: "User ID is required to delete" });
        }

        let deletedUser = await User.findByIdAndDelete(id);

        if (!deletedUser) {
            return res
                .status(404)
                .json({ message: "User with that ID is not found" });
        }
        return res
            .status(200)
            .json({ message: `User deleted with name: ${deletedUser.name}` });
    } catch (err) {
        console.error(`BAD DELETE REQUEST USER!! \n Error: ${err}`);
        return res
            .status(500)
            .json({ message: "DELETE request user failed. Try again" });
    }
};

// PATCH request: updates the equipped outfit for a particular user
export const updateOutfit = async (req, res) => {
    try {
        const { userId, outfitNumber, category, itemId } = req.params;

        // Validating request
        const errors = [];
        if (!userId || !mongoose.Types.ObjectId.isValid(userId)) {
            errors.push("Invalid user ID");
        }
        if (!["1", "2", "3"].includes(outfitNumber)) {
            errors.push("Outfit number must be 1, 2, or 3");
        }
        const validCategories = [
            "tops",
            "bottoms",
            "shoes",
            "outerwear",
            "accessories",
        ];
        if (!validCategories.includes(category)) {
            errors.push("Invalid category");
        }
        if (!itemId || !mongoose.Types.ObjectId.isValid(itemId)) {
            errors.push("Invalid item ID");
        }
        if (errors.length > 0) {
            return res.status(400).json({
                message: "Validation failed",
                errors: errors,
            });
        }

        // Find user
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        // Build the outfit field name (outfit1, outfit2, or outfit3)
        const outfitField = `outfit${outfitNumber}`;
        if (!user[outfitField]) {
            user[outfitField] = {};
        }

        // Update the specific category in the outfit
        user[outfitField][category] = itemId;

        // Mark the field as modified (important for nested objects)
        user.markModified(outfitField);

        // Save the user
        await user.save();

        console.log(`Updated ${outfitField}.${category} for user ${userId}`);
        res.status(200).json({
            message: "Outfit updated successfully",
            outfit: user[outfitField],
        });
    } catch (err) {
        console.error(`Failed to update outfit: ${err}`);
        res.status(500).json({ message: "Failed to update outfit" });
    }
};

// POST request: Generates outfit image for a user's specified outfit
export const generateOutfit = async (req, res) => {
    try {
        const { userId, outfitNumber } = req.params;
        const { picture } = req.body;

        // Validating request parameters
        const errors = [];
        if (!userId || !mongoose.Types.ObjectId.isValid(userId)) {
            errors.push("Invalid user ID");
        }
        if (!["1", "2", "3"].includes(outfitNumber)) {
            errors.push("Outfit number must be 1, 2, or 3");
        }
        if (!picture || typeof picture !== "string") {
            errors.push("Picture is required and must be a string");
        } else if (!picture.startsWith("data:image/")) {
            errors.push("Picture must be a valid base64 image data URL");
        }
        if (errors.length > 0) {
            return res.status(400).json({
                message: "Validation failed",
                errors: errors,
            });
        }

        // Find user and outfit
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }
        const outfitField = `outfit${outfitNumber}`;
        const outfit = user[outfitField];
        if (!outfit || Object.keys(outfit).length === 0) {
            return res.status(400).json({ message: "Outfit is empty" });
        }

        // Get all item IDs from outfit
        const itemIds = Object.values(outfit);

        // Fetch all wardrobe items
        const wardrobeItems = await ClothingItem.find({
            _id: { $in: itemIds },
        });

        // Build clothing items array for Gemini 3
        const clothingItems = wardrobeItems.map((item) => ({
            image: item.image_data,
            category: item.category,
        }));

        // Generate outfit image using Gemini 3
        console.log(
            `Generate outfit requested for user ${userId}, outfit ${outfitNumber} with ${clothingItems.length} items`
        );
        const generatedImage = await generateOutfitImageGemini3(
            picture,
            clothingItems
        );

        // Return generated outfit image
        return res.status(200).json({
            message: "Outfit generated successfully",
            userId: userId,
            outfitNumber: outfitNumber,
            outfit: outfit,
            generatedImage: generatedImage,
        });
    } catch (err) {
        console.error(`Failed to generate outfit: ${err}`);
        res.status(500).json({ message: "Failed to generate outfit" });
    }
};
