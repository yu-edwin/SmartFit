import Outfit from "../models/outfitSchema.js";

// GET Obtain all outfits by the userID
export const getOutfitsByUserId = async (req, res) => {
    console.log("Attemping GET for all outfits");
    try {
        const { userId } = req.params;
        if (!userId) {
            return res.status(400).json({ message: "Provided invalid userID" });
        }
        const outfits = await Outfit.find({ userId })
            .populate("tops")
            .populate("bottoms")
            .populate("shoes")
            .populate("outerwear")
            .populate("accessories");

        if (outfits.length == 0) {
            return res
                .status(404)
                .json({ message: "No outfits found for this user." });
        }

        console.log("Found outfits!!");
        res.status(200).json(outfits);
    } catch (err) {
        console.error(`Error trying to GET ALL OUTFITS... ERROR: ${err}`);
        res.status(500).json({ message: `Failed... here is error: ${err}` });
    }
};

// POST creatOutfit
export const createOutfit = async (req, res) => {
    console.log("Attemping to create outfit...");
    try {
        const { userId, tops, bottoms, shoes, outerwear, accessories } =
            req.body;

        if (!userId) {
            return res
                .status(400)
                .json({ message: "Invalid User Id. Try again." });
        }

        // if (!mongoose.Types.ObjectId.isValid(userId) ||
        //     !mongoose.Types.ObjectId.isValid(tops) ||
        //     !mongoose.Types.ObjectId.isValid(bottoms) ||
        //     !mongoose.Types.ObjectId.isValid(shoes) ||
        //     !mongoose.Types.ObjectId.isValid(outerwear) ||
        //     !mongoose.Types.ObjectId.isValid(accessories)
        // ) {
        //     return res.status(400).json({ message: `One of the items provided is an invalid mongoose ObjectID. Try again` });
        // }

        const newOutfit = new Outfit({
            userId,
            tops: tops || null,
            bottoms: bottoms || null,
            shoes: shoes || null,
            outerwear: outerwear || null,
            accessories: accessories || null,
        });

        const savedOutfit = await newOutfit.save();
        console.log("Successfully created a new outfit");
        res.status(201).json(savedOutfit);
    } catch (err) {
        console.error(`Failed POST createOutfit... Error: ${err}`);
        res.status(500).json({ message: `Failed... here is error: ${err}` });
    }
};
