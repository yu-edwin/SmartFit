import mongoose from "mongoose";

const { Schema } = mongoose;

const clothingItem = new Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
    },
    category: {
        type: String,
        enum: ["tops", "bottoms", "shoes", "outerwear", "accessories"],
        required: true,
        lowercase: true,
        trim: true,
    },
    name: {
        type: String,
        required: true,
        trim: true,
    },
    color: {
        type: String,
        required: true,
        lowercase: true,
        trim: true,
    },
    size: {
        type: String,
        required: true,
        set: (v) => v.toUpperCase(),
        trim: true,
    },
    price: {
        type: Number,
        min: 0,
        default: 0,
    },
    brand: String,
    material: String,
    description: String,
    image_url: String,
    image_data: String,
    item_url: String,
    createdAt: {
        type: Date,
        default: () => Date.now(),
    },
});

clothingItem.index({ userId: 1, category: 1 });
clothingItem.index({ userId: 1, createdAt: -1 });

export default mongoose.model("Wardrobeitem", clothingItem);
