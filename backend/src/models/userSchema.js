import mongoose from "mongoose";

const { Schema } = mongoose;

const userSchema = new Schema({
    name: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        unique: true,
        required: true,
    },
    password: {
        type: String,
        minlength: 5,
        required: true,
    },
    createdAt: {
        type: Date,
        default: () => Date.now(),
        immutable: true,
    },
    outfit1: {
        type: Object,
        default: {},
    },
    outfit2: {
        type: Object,
        default: {},
    },
    outfit3: {
        type: Object,
        default: {},
    },
});

export default mongoose.model("User", userSchema);
