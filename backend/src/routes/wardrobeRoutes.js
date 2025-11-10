import express from "express";
import {
    getAllItems,
    createClothingItem,
    deleteClothingItem,
    updateClothingItem,
} from "../controller/wardrobeController.js";

const router = express.Router();

router.get("/", getAllItems);
router.post("/", createClothingItem);
router.put("/:id", updateClothingItem);
router.delete("/:id", deleteClothingItem);

export default router;
