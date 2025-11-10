import { isValidEmail, isValidPassword } from "../../src/utils/validation.js";

describe("Validation utilities", () => {
    test("Valid email should return true", () => {
        expect(isValidEmail("user@example.com")).toBe(true);
    });

    test("Invalid email should return false", () => {
        expect(isValidEmail("not-an-email")).toBe(false);
    });

    test("Valid password should return true", () => {
        expect(isValidPassword("MyPassword123!")).toBe(true);
    });

    test("Invalid password should return false", () => {
        expect(isValidPassword("abc")).toBe(false);
    });
});
