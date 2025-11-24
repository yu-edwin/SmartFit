// backend/test/manualTest.js として作成してテスト可能
import { scrapeProductInfo } from "../src/services/productScraperService.js";

const testUrls = [
    "https://www.uniqlo.com/jp/ja/products/E461895",
    "https://www.zara.com/jp/ja/product-page.html",
    "https://www2.hm.com/ja_jp/product-page.html",
];

for (const url of testUrls) {
    console.log("Testing:", url);
    const result = await scrapeProductInfo(url);
    console.log(result);
}
