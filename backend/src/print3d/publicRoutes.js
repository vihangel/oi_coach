/** @format */

const router = require("express").Router();
const { ObjectId } = require("mongodb");
const { getDb } = require("./db");

function code(prefix) {
  return `${prefix}-${Date.now().toString().slice(-6)}`;
}

// ---------------------------------------------------------------------------
// Customer products (publico)
// ---------------------------------------------------------------------------

router.get("/customer-products", (_req, res) => {
  res.json([
    {
      id: "cat_keyring",
      title: "Chaveiros",
      description: "Chaveiros personalizados com nome, logo ou personagem.",
      icon: "key",
      examples: ["brinde", "nome", "logo", "evento"],
      fromPriceCents: 1290,
      needsImage: false,
    },
    {
      id: "cat_miniature",
      title: "Miniaturas",
      description: "Bonecos, pecas de RPG e miniaturas detalhadas.",
      icon: "miniature",
      examples: ["boneco", "RPG", "tabuleiro", "personagem"],
      fromPriceCents: 3490,
      needsImage: false,
    },
    {
      id: "cat_decor",
      title: "Decoracao",
      description: "Pecas para mesa, parede, festas, nichos e ambientes.",
      icon: "decor",
      examples: ["mesa", "festa", "parede", "presente"],
      fromPriceCents: 3490,
      needsImage: false,
    },
    {
      id: "cat_sign",
      title: "Placas e letreiros",
      description: "Placas com relevo, letreiros, logos e quadros decorativos.",
      icon: "frame",
      examples: ["logo 3D", "letreiro", "placa", "quadro"],
      fromPriceCents: 5990,
      needsImage: false,
    },
    {
      id: "cat_lamp",
      title: "Luminarias",
      description:
        "Luminarias litofane, abajures geometricos e personalizados.",
      icon: "lamp",
      examples: ["litofane", "abajur", "luz", "foto"],
      fromPriceCents: 5990,
      needsImage: false,
    },
    {
      id: "cat_other",
      title: "Outros",
      description:
        "Conte sua ideia em aberto: peca tecnica, reposicao ou presente.",
      icon: "other",
      examples: ["peca tecnica", "suporte", "miniatura", "prototipo"],
      fromPriceCents: 2990,
      needsImage: false,
    },
  ]);
});

// ---------------------------------------------------------------------------
// Catalog (publico)
// ---------------------------------------------------------------------------

router.get("/catalog", async (req, res, next) => {
  try {
    const db = await getDb();
    const { categoryId } = req.query;
    const filter = categoryId ? { categoryId } : {};
    const items = await db
      .collection("catalog_items")
      .find(filter)
      .sort({ title: 1 })
      .toArray();
    res.json(items);
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Customer orders (publico)
// ---------------------------------------------------------------------------

router.get("/customer-orders", async (req, res, next) => {
  try {
    const db = await getDb();
    const email = String(req.query.email || "")
      .trim()
      .toLowerCase();
    const filter = email ? { email } : {};
    const orders = await db
      .collection("customer_orders")
      .find(filter)
      .sort({ createdAt: -1 })
      .limit(100)
      .toArray();
    res.json(orders);
  } catch (error) {
    next(error);
  }
});

router.post("/customer-orders", async (req, res, next) => {
  try {
    const db = await getDb();
    const now = new Date();
    const order = {
      code: code("PED"),
      customerName: req.body.customerName,
      email: String(req.body.email || "")
        .trim()
        .toLowerCase(),
      phone: req.body.phone,
      kind: req.body.kind || "person",
      productTitle: req.body.productTitle,
      description: req.body.description,
      quantity: Number(req.body.quantity || 1),
      hasReferenceImage: Boolean(req.body.hasReferenceImage),
      status: "received",
      createdAt: now,
      updatedAt: now,
    };
    const result = await db.collection("customer_orders").insertOne(order);
    res.status(201).json({ ...order, _id: result.insertedId });
  } catch (error) {
    next(error);
  }
});

router.patch("/customer-orders/:id/status", async (req, res, next) => {
  try {
    const db = await getDb();
    await db
      .collection("customer_orders")
      .updateOne(
        { _id: new ObjectId(req.params.id) },
        { $set: { status: req.body.status, updatedAt: new Date() } },
      );
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
