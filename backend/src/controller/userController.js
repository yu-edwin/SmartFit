import bcrypt from "bcrypt";
import mongoose from "mongoose";
import User from "../models/userSchema.js";
import { isValidEmail, isValidPassword } from "../utils/validation.js";

// GET request: Gets all info from user.
export const getUserInfo = async (req, res) => {
    try {
        const { id } = req.params;
        // console.log("Trying to fetch user")
        if (!id || !mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({ message: "Provided invalid ID" });
        }

        const user = await User.findById(id);
        if (!user) {
            return res
                .status(404)
                .json({ message: `User not found by ID: ${id}` });
        }
        // console.log("Found user!");
        res.status(200).json({ user });
    } catch (err) {
        console.error(`Cannot fetch user based on ID... Here is error: ${err}`);
        return res
            .status(500)
            .json({ message: "Server Error trying to get USER INFO BY ID" });
    }
};

// POST request: Request to be called when creating a new user
/*
1. Checks valid name, email, and password in req.body
2. Checks if email/password is valid
3. Checks if email already exists
4. Hash password
5. Create User
*/
export const createUserInfo = async (req, res) => {
    try {
        const { name, email, password } = req.body;
        if (!name || !email || !password) {
            return res
                .status(400)
                .json({ message: "Username, email, and password required" });
        }

        if (!isValidEmail(email)) {
            return res
                .status(400)
                .json({ message: "Email is not valid. Try again" });
        }

        if (!isValidPassword(password)) {
            return res
                .status(400)
                .json({ message: "Password not valid. Try again" });
        }
        const locateUser = await User.findOne({ email });

        if (locateUser) {
            return res.status(400).json({
                message: "Email already in use. Please use another email",
            });
        }

        const hashPassword = await bcrypt.hash(password, 10);

        const newUser = await User.create({
            name: name,
            email: email,
            password: hashPassword,
        });
        if (newUser) {
            // Return user data without password
            const userResponse = {
                id: newUser._id,
                name: newUser.name,
                email: newUser.email,
                createdAt: newUser.createdAt,
            };
            console.log("Successfully Created a user!!");
            return res.status(201).json({
                message: "User successfully created!",
                user: userResponse,
            });
        } else {
            return res.status(400).json({ message: "Error creating new user" });
        }
    } catch (err) {
        console.error(`POST Request failed!! Error msg: ${err}`);
        return res
            .status(500)
            .json({ message: "POST request failed. Try again" });
    }
};

// POST request: Login user with email and password
export const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res
                .status(400)
                .json({ message: "Email and password are required" });
        }

        if (!isValidEmail(email)) {
            return res.status(400).json({ message: "Email is not valid" });
        }

        const user = await User.findOne({ email });

        if (!user) {
            return res
                .status(401)
                .json({ message: "Invalid email or password" });
        }

        const isPasswordValid = await bcrypt.compare(password, user.password);

        if (!isPasswordValid) {
            return res
                .status(401)
                .json({ message: "Invalid email or password" });
        }

        // Return user data without password
        const userResponse = {
            id: user._id,
            name: user.name,
            email: user.email,
            createdAt: user.createdAt,
        };

        return res.status(200).json({
            message: "Login successful",
            user: userResponse,
        });
    } catch (err) {
        console.error(`Login failed!! Error: ${err}`);
        return res.status(500).json({ message: "Login failed. Try again" });
    }
};

// DELETE request: Deletes a user based on ID provided
export const deleteUser = async (req, res) => {
    try {
        const { id } = req.params;

        if (!id || !mongoose.Types.ObjectId.isValid(id)) {
            return res
                .status(400)
                .json({ message: "User ID is required to delete" });
        }

        let deletedUser = await User.findByIdAndDelete(id);

        if (!deletedUser) {
            return res
                .status(404)
                .json({ message: "User with that ID is not found" });
        }
        return res
            .status(200)
            .json({ message: `User deleted with name: ${deletedUser.name}` });
    } catch (err) {
        console.error(`BAD DELETE REQUEST USER!! \n Error: ${err}`);
        return res
            .status(500)
            .json({ message: "DELETE request user failed. Try again" });
    }
};
