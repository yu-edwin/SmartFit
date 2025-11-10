import js from "@eslint/js";
import globals from "globals";
import { defineConfig } from "eslint/config";

export default defineConfig([
    {
        files: ["**/*.{js,mjs,cjs}"],
        ignores: ["node_modules/**", "dist/**"],
        plugins: { js },
        extends: ["js/recommended"],
        languageOptions: {
            ecmaVersion: 2022,
            sourceType: "module",
            globals: {
                ...globals.node,
                myCustomGlobal: "readonly",
                ...globals.jest,
            },
        },
        rules: {
            "no-unused-vars": "warn",
            "no-undef": "warn",
        },
    },
]);
