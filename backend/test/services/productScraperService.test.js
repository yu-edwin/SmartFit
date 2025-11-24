// backend/test/services/productScraperService.test.js
import axios from "axios";
import {
    scrapeProductInfo,
    isValidProductUrl,
} from "../../src/services/productScraperService.js";

// Mock axios
jest.mock("axios");

describe("productScraperService", () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    // MARK: - URL Validation Tests
    describe("isValidProductUrl", () => {
        it("should return true for valid URLs", () => {
            expect(
                isValidProductUrl("https://www.uniqlo.com/product/123")
            ).toBe(true);
            expect(isValidProductUrl("https://www.zara.com/item/456")).toBe(
                true
            );
            expect(isValidProductUrl("https://www2.hm.com/product/789")).toBe(
                true
            );
        });

        it("should return false for invalid URLs", () => {
            expect(isValidProductUrl("not-a-url")).toBe(false);
            expect(isValidProductUrl("")).toBe(false);
        });
    });

    // MARK: - Scraping Tests
    describe("scrapeProductInfo", () => {
        it("should scrape UNIQLO product successfully", async () => {
            // Mock HTML response
            const mockHtml = `
        <html>
          <head>
            <title>Test Product</title>
            <meta property="og:title" content="UNIQLO Cotton T-Shirt" />
            <meta property="og:image" content="https://example.com/image.jpg" />
          </head>
          <body>
            <h1 class="heading-primary">UNIQLO Cotton T-Shirt</h1>
            <div class="price-value">$19.90</div>
            <div class="color-name">Blue</div>
            <div class="item-material">93% Cotton, 7% Spandex</div>
          </body>
        </html>
      `;

            // Mock axios responses
            axios.get.mockResolvedValueOnce({
                data: mockHtml,
                headers: { "content-type": "text/html" },
            });

            // Mock image download
            axios.get.mockResolvedValueOnce({
                data: Buffer.from("fake-image-data"),
                headers: { "content-type": "image/jpeg" },
            });

            const result = await scrapeProductInfo(
                "https://www.uniqlo.com/product/123"
            );

            expect(result.name).toBe("UNIQLO Cotton T-Shirt");
            expect(result.brand).toBe("UNIQLO");
            expect(result.price).toBe(19.9);
            expect(result.color).toBe("Blue");
            expect(result.material).toContain("Cotton");
            expect(result.category).toBe("tops");
            expect(result.scraped_successfully).toBe(true);
        });

        it("should handle scraping errors gracefully", async () => {
            // Mock axios to throw error
            axios.get.mockRejectedValueOnce(new Error("Network error"));

            const result = await scrapeProductInfo(
                "https://www.uniqlo.com/product/123"
            );

            expect(result.name).toBe("Imported Item");
            expect(result.scraped_successfully).toBe(false);
            expect(result.price).toBe(0);
        });

        it("should extract price correctly from text", async () => {
            const mockHtml = `
        <html>
          <body>
            <h1>Test Product</h1>
            <div class="price-value">$29.99</div>
          </body>
        </html>
      `;

            axios.get.mockResolvedValueOnce({
                data: mockHtml,
                headers: { "content-type": "text/html" },
            });

            const result = await scrapeProductInfo(
                "https://www.uniqlo.com/product/456"
            );

            expect(result.price).toBe(29.99);
        });

        it("should fallback to meta tags when site-specific selectors fail", async () => {
            const mockHtml = `
        <html>
          <head>
            <meta property="og:title" content="Generic Product" />
            <meta property="og:image" content="https://example.com/img.jpg" />
          </head>
          <body>
            <p>No specific selectors here</p>
          </body>
        </html>
      `;

            axios.get.mockResolvedValueOnce({
                data: mockHtml,
                headers: { "content-type": "text/html" },
            });

            const result = await scrapeProductInfo(
                "https://www.uniqlo.com/product/789"
            );

            expect(result.name).toBe("Generic Product");
            expect(result.scraped_successfully).toBe(true);
        });
    });
});
