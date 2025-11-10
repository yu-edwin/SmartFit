import dotenv from "dotenv";
import express from "express";
import cors from "cors";
import connectToDB from "./src/config/mongoDBConnection.js";
import seedData from "./src/config/seedData.js";
import wardrobeRoutes from "./src/routes/wardrobeRoutes.js";
import userRoutes from "./src/routes/userRoutes.js";
import outfitRoutes from "./src/routes/outfitRoutes.js";

dotenv.config({ path: process.env.NODE_ENV === "test" ? ".env.test" : ".env" });
const app = express();
app.use(cors());
app.use(express.json({ limit: "50mb" }));

// Log all requests
app.use((req, res, next) => {
    // console.log(`${req.method} ${req.url}`);
    next();
});

app.use("/api/outfit", outfitRoutes);
app.use("/api/user", userRoutes);
app.use("/api/wardrobe", wardrobeRoutes);
console.log("Routes are supported");

// Test route
app.get("/api/test", (req, res) => {
    res.json({ message: "API is working!" });
});

if (process.env.NODE_ENV !== "test") {
    const startServer = async () => {
        await connectToDB();
        await seedData();
    };
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

    startServer();
}
// Export app for Jest/Supertest
export default app;
