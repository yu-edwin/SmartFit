import express from "express";
import {
    getUserInfo,
    createUserInfo,
    deleteUser,
    loginUser,
    updateOutfit,
    generateOutfit,
} from "../controller/userController.js";

const router = express.Router();

router.get("/:id", getUserInfo);
router.post("/register", createUserInfo);
router.post("/login", loginUser);
router.delete("/:id", deleteUser);
router.patch("/:userId/:outfitNumber/:category/:itemId", updateOutfit);
router.post("/:userId/generate-outfit/:outfitNumber", generateOutfit);

export default router;
