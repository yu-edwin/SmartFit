import express from "express";
import {
    getOutfitsByUserId,
    createOutfit,
} from "../controller/outfitController.js";

const router = express.Router();

router.get("/:userId", getOutfitsByUserId);
router.post("/", createOutfit);

export default router;
