import express from "express";
import {
    getAllItems,
    createClothingItem,
    deleteClothingItem,
    updateClothingItem,
    importFromUrl
} from "../controller/wardrobeController.js";

const router = express.Router();

router.get("/", getAllItems);
router.post("/", createClothingItem);
router.put("/:id", updateClothingItem);
router.delete("/:id", deleteClothingItem);
router.post("/import-url", importFromUrl);

export default router;
