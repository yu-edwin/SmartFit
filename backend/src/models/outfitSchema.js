import mongoose from "mongoose";

const { Schema } = mongoose;

const outfit = new Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
    },
    tops: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Wardrobeitem",
        lowercase: true,
    },
    bottoms: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Wardrobeitem",
        lowercase: true,
    },
    shoes: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Wardrobeitem",
        lowercase: true,
    },
    outerwear: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Wardrobeitem",
        lowercase: true,
    },
    accessories: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Wardrobeitem",
        lowercase: true,
    },
});

export default mongoose.model("Outfit", outfit);
