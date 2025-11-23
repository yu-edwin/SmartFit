import express from "express";
import {
    getUserInfo,
    createUserInfo,
    deleteUser,
    loginUser,
    updateOutfit,
} from "../controller/userController.js";

const router = express.Router();

router.get("/:id", getUserInfo);
router.post("/register", createUserInfo);
router.post("/login", loginUser);
router.delete("/:id", deleteUser);
router.patch("/:userId/:outfitNumber/:category/:itemId", updateOutfit);

export default router;
