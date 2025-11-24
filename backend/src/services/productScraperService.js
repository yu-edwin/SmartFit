// backend/src/services/productScraperService.js
import axios from "axios";
import * as cheerio from "cheerio";

// Site-specific selectors
const SITE_CONFIGS = {
  "uniqlo.com": {
    name: "h1.heading-primary, .product-name",
    // UNIQLO: try many price patterns
    price: `
      .price-value,
      .product-price__price,
      .product-detail__price,
      .product__price,
      .product-sales-price,
      [data-test="product-price"],
      [class*="Price-module"],
      [class*="product-price"],
      .fr-ec-price-text
    `,
    color: ".color-name, [data-test='product-color']",
    image: ".product-image img, .product-detail-main-image-container img",
    // UNIQLO: container that usually includes "93% Cotton, 7% Spandex" etc.
    material: ".item-material, .product-detail-description, [data-test='composition']",
    brand: "UNIQLO",
  },
  "zara.com": {
    name: "h1.product-detail-info__header-name",
    price: ".price__amount-current",
    color: ".product-detail-selected-color",
    image: ".media-image__image",
    // Try material section if present
    material: ".product-detail-info__composition, .product-detail-description",
    brand: "ZARA",
  },
  "hm.com": {
    name: "h1.product-item-headline",
    price: `
      .price-value,
      [data-testid="price"],
      [class*="Price"],
      [class*="price"]
    `,
    color: ".product-color, .ProductDescription-module--colorName--*",
    image: ".product-image img, .product-detail-main-image-container img",
    material: ".pdp-description-list-item, .pdp-description-text, .ProductMaterial-module--details--*",
    brand: "H&M",
  },
  "amazon.com": {
    name: "#productTitle",
    price:
      "#corePrice_feature_div span.a-offscreen, #priceblock_ourprice, #priceblock_dealprice",
    color: "#variation_color_name .selection",
    image: "#imgTagWrapperId img, #landingImage",
    brand: "#bylineInfo",
  },
};

const getSiteConfig = (url) => {
  try {
    const urlObj = new URL(url);
    const hostname = urlObj.hostname.toLowerCase().replace(/^www\./, "");

    for (const [pattern, config] of Object.entries(SITE_CONFIGS)) {
      if (hostname.endsWith(pattern)) {
        return config;
      }
    }
    return null;
  } catch {
    return null;
  }
};

const extractPrice = (priceText) => {
  if (!priceText) return 0;
  const cleanPrice = priceText.replace(/[^0-9.]/g, "");
  const price = parseFloat(cleanPrice);
  return Number.isNaN(price) ? 0 : price;
};

const guessCategory = (name) => {
  const lowerName = name.toLowerCase();
  if (/shirt|blouse|tee|t-shirt|top|sweater/.test(lowerName)) return "tops";
  if (/pants|jeans|shorts|skirt|trousers/.test(lowerName)) return "bottoms";
  if (/shoe|sneaker|boot|loafer/.test(lowerName)) return "shoes";
  if (/jacket|coat|parka|blazer/.test(lowerName)) return "outerwear";
  if (/hat|scarf|bag|belt/.test(lowerName)) return "accessories";
  return "tops";
};

// Normalize and shorten material text
const cleanMaterial = (text) => {
  if (!text) return "";

  const normalized = text.replace(/\s+/g, " ").trim();

  // Prefer patterns like "93% Cotton, 7% Spandex"
  const percentPattern =
    /(\d{1,3}\s*[%％]\s*[A-Za-z]+(?:\s*,\s*\d{1,3}\s*[%％]\s*[A-Za-z]+)*)/;
  const match = normalized.match(percentPattern);
  if (match && match[1]) {
    return match[1].trim();
  }

  // Otherwise just keep first short sentence
  let result = normalized.split(/[。.]/)[0].trim();
  if (result.length > 60) {
    result = result.slice(0, 57) + "...";
  }
  return result;
};

// Generic "material-like" text finder (fallback)
const extractMaterial = ($) => {
  const keywords =
    /(cotton|polyester|nylon|wool|rayon|linen|acrylic|spandex|elastane)/i;

  let found = "";
  $("*").each((_, el) => {
    if (found) return;
    const text = $(el).text().trim();
    if (
      keywords.test(text) &&
      text.length > 0 &&
      text.length < 400 // safety bound
    ) {
      found = cleanMaterial(text);
    }
  });
  return found;
};

// Meta tag based scraping (title, image, sometimes price)
const scrapeFromMetaTags = ($, productUrl) => {
  const ogTitle =
    $('meta[property="og:title"]').attr("content") ||
    $('meta[name="twitter:title"]').attr("content") ||
    "";

  const ogImage =
    $('meta[property="og:image"]').attr("content") ||
    $('meta[name="twitter:image"]').attr("content") ||
    "";

  const ogPrice =
    $('meta[property="product:price:amount"]').attr("content") ||
    $('meta[property="og:price:amount"]').attr("content") ||
    "";

  const name =
    ogTitle ||
    $('meta[name="title"]').attr("content") ||
    $("title").text().trim() ||
    "Imported Item";

  const price = extractPrice(ogPrice);
  let imageUrl = ogImage;

  if (!imageUrl) {
    // fallback: first <img>
    imageUrl = $("img").first().attr("src") || "";
  }

  if (imageUrl && !imageUrl.startsWith("http")) {
    try {
      const base = new URL(productUrl).origin;
      imageUrl = base + imageUrl;
    } catch {
      // ignore
    }
  }

  return { name, price, imageUrl };
};

// Download image and convert to base64
const downloadImageAsBase64 = async (imageUrl) => {
  const res = await axios.get(imageUrl, {
    responseType: "arraybuffer",
    timeout: 5000,
  });

  const contentType = res.headers["content-type"] || "image/jpeg";
  const base64 = Buffer.from(res.data, "binary").toString("base64");
  return `data:${contentType};base64,${base64}`;
};

export const scrapeProductInfo = async (productUrl) => {
  const config = getSiteConfig(productUrl);

  try {
    const response = await axios.get(productUrl, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36",
      },
      timeout: 10000,
    });

    const $ = cheerio.load(response.data);

    // First: meta tags
    const metaResult = scrapeFromMetaTags($, productUrl);
    let { name, price, imageUrl } = metaResult;

    // Generic material extraction (will be overridden by site-specific rules)
    let material = extractMaterial($);

    // Site-specific overrides
    if (config) {
      // Name
      const nameFromConfig = $(config.name).first().text().trim();
      if (nameFromConfig) name = nameFromConfig;

      // Price
      const priceText = config.price
        ? $(config.price).first().text().trim()
        : "";
      if (priceText) price = extractPrice(priceText);

      // Color
      const colorFromConfig = config.color
        ? $(config.color).first().text().trim()
        : "";
      const color = colorFromConfig || "";

      // Image
      let imageFromConfig = config.image
        ? $(config.image).first().attr("src")
        : null;

      if (imageFromConfig) {
        if (!imageFromConfig.startsWith("http")) {
          const base = new URL(productUrl).origin;
          imageFromConfig = base + imageFromConfig;
        }
        imageUrl = imageFromConfig;
      }

      // Material (site-specific selector → then cleanMaterial)
      if (config.material) {
        const matRoot = $(config.material).first();
        let matText = matRoot.text().trim();

        // Prefer the first child text that contains a percent sign
        let percentLine = "";
        matRoot.find("*").each((_, el) => {
          if (percentLine) return;
          const t = $(el).text().trim();
          if (/[％%]/.test(t)) {
            percentLine = t;
          }
        });
        if (percentLine) {
          matText = percentLine;
        }

        if (matText) {
          material = cleanMaterial(matText);
        } else {
          material = cleanMaterial(material);
        }
      } else {
        material = cleanMaterial(material);
      }

      // Image data
      let imageData = null;
      if (imageUrl) {
        try {
          imageData = await downloadImageAsBase64(imageUrl);
        } catch (err) {
          console.log("Image download failed:", err.message);
        }
      }

      return {
        name: name.substring(0, 100),
        brand:
          typeof config.brand === "string"
            ? config.brand
            : "",
        price,
        color,
        category: guessCategory(name),
        item_url: productUrl,
        image_data: imageData,
        material: material || "",
        scraped_successfully: true,
      };
    }

    // Unsupported sites: meta + generic fallback only
    material = cleanMaterial(material);

    let imageData = null;
    if (imageUrl) {
      try {
        imageData = await downloadImageAsBase64(imageUrl);
      } catch (err) {
        console.log("Image download failed:", err.message);
      }
    }

    return {
      name: name.substring(0, 100),
      brand: "",
      price,
      color: "",
      category: guessCategory(name),
      item_url: productUrl,
      image_data: imageData,
      material: material || "",
      scraped_successfully: true,
    };
  } catch (error) {
    console.error("Scraping error:", error.message);
    return {
      name: "Imported Item",
      brand: "",
      price: 0,
      color: "",
      category: "tops",
      item_url: productUrl,
      image_data: null,
      material: "",
      scraped_successfully: false,
    };
  }
};

export const isValidProductUrl = (url) => {
  try {
    // Only check if it looks like a valid URL (no domain restriction)
    // eslint-disable-next-line no-new
    new URL(url);
    // add here to reject unsupported URLs
    return getSiteConfig(url) !== null;
  } catch {
    return false;
  }
};
