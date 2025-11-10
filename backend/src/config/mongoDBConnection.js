import mongoose from "mongoose";
import dotenv from "dotenv";

// Load the correct environment file FIRST
const envPath = process.env.NODE_ENV === "test" ? ".env.test" : ".env";
dotenv.config({ path: envPath });

const uri =
    process.env.NODE_ENV === "test"
        ? process.env.MONGODB_URI
        : process.env.MONGODB_URI;

export const connectToDB = async () => {
    try {
        await mongoose.connect(uri);
        console.log(
            `Connected to MongoDB Atlas — ${uri.includes("test") ? "TEST DATABASE" : "MAIN DATABASE"}`
        );
    } catch (err) {
        console.error(
            "UNABLE TO CONNECT TO MONGO! CHECK MONGODB_URI ENVIRONMENT VARIABLE\n",
            err.message
        );
        if (process.env.NODE_ENV !== "test") process.exit(1);
        else throw err;
    }
};

export const disconnectDb = async () => {
    await mongoose.connection.close();
    console.log("Disconnected from MongoDB");
};

export default connectToDB;
