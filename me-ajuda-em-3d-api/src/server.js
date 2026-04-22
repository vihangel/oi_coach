/** @format */

import cors from "cors";
import "dotenv/config";
import express from "express";
import multer from "multer";
import { getDb } from "./db.js";

const app = express();
const upload = multer({ dest: "uploads/" });
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: "1mb" }));
app.use("/uploads", express.static("uploads"));

function code(prefix) {
  return `${prefix}-${Date.now().toString().slice(-6)}`;
}

app.get("/health", (_, res) => res.json({ ok: true }));

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------

app.get("/dashboard", async (_, res, next) => {
  try {
    const db = await getDb();
    const [quotes, jobs, materials] = await Promise.all([
      db.collection("quotes").find().toArray(),
      db.collection("jobs").find().toArray(),
      db.collection("materials").find().toArray(),
    ]);
    const now = new Date();
    const in36h = new Date(now.getTime() + 36 * 60 * 60 * 1000);
    res.json({
      pendingQuotes: quotes.filter(
        (q) => q.status === "draft" || q.status === "sent",
      ).length,
      inProduction: jobs.filter(
        (j) => j.status === "queue" || j.status === "printing",
      ).length,
      readyPickup: jobs.filter((j) => j.status === "readyPickup").length,
      lowFilaments: materials.filter(
        (m) =>
          m.remainingGrams != null &&
          m.lowStockGrams != null &&
          m.remainingGrams <= m.lowStockGrams,
      ).length,
      criticalDeadlines: jobs.filter(
        (j) =>
          j.dueAt && new Date(j.dueAt) <= in36h && j.status !== "delivered",
      ).length,
    });
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Customer products (rota publica)
// ---------------------------------------------------------------------------

app.get("/customer-products", (_, res) => {
  res.json([
    {
      id: "keyring",
      title: "Chaveiro personalizado",
      description: "Nome, logo, personagem simples ou lembrancinha em lote.",
      icon: "key",
      examples: ["brinde", "nome", "logo", "evento"],
      fromPriceCents: 1290,
      needsImage: false,
    },
    {
      id: "decor",
      title: "Encomenda decoracao",
      description: "Pecas para mesa, parede, festas, nichos e ambientes.",
      icon: "decor",
      examples: ["mesa", "festa", "parede", "presente"],
      fromPriceCents: 3490,
      needsImage: false,
    },
    {
      id: "frame",
      title: "Quadro ou placa",
      description: "Placas com relevo, letreiros, logos e quadros decorativos.",
      icon: "frame",
      examples: ["logo 3D", "letreiro", "placa", "quadro"],
      fromPriceCents: 5990,
      needsImage: false,
    },
    {
      id: "image",
      title: "Pedido com base em imagem",
      description: "Envie uma foto ou referencia para avaliarmos a modelagem.",
      icon: "image",
      examples: ["foto", "desenho", "referencia", "print"],
      fromPriceCents: 4590,
      needsImage: true,
    },
    {
      id: "other",
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
// Customer orders (rota publica)
// ---------------------------------------------------------------------------

app.get("/customer-orders", async (req, res, next) => {
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

app.post("/customer-orders", async (req, res, next) => {
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

app.patch("/customer-orders/:id/status", async (req, res, next) => {
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

// ---------------------------------------------------------------------------
// Uploads
// ---------------------------------------------------------------------------

app.post("/uploads", upload.single("file"), async (req, res, next) => {
  try {
    const db = await getDb();
    const doc = {
      orderId: req.body.orderId ? new ObjectId(req.body.orderId) : null,
      originalName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size,
      path: req.file.path,
      url: `${process.env.PUBLIC_BASE_URL || ""}/${req.file.path}`,
      createdAt: new Date(),
    };
    const result = await db.collection("uploads").insertOne(doc);
    res.status(201).json({ ...doc, _id: result.insertedId });
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Clients
// ---------------------------------------------------------------------------

app.get("/clients", async (_, res, next) => {
  try {
    const db = await getDb();
    res.json(
      await db.collection("clients").find().sort({ createdAt: -1 }).toArray(),
    );
  } catch (error) {
    next(error);
  }
});

app.post("/clients", async (req, res, next) => {
  try {
    const db = await getDb();
    const client = { ...req.body, isActive: true, createdAt: new Date() };
    const result = await db.collection("clients").insertOne(client);
    res.status(201).json({ ...client, _id: result.insertedId });
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Materials
// ---------------------------------------------------------------------------

app.get("/materials", async (_, res, next) => {
  try {
    const db = await getDb();
    res.json(
      await db.collection("materials").find().sort({ createdAt: -1 }).toArray(),
    );
  } catch (error) {
    next(error);
  }
});

app.post("/materials", async (req, res, next) => {
  try {
    const db = await getDb();
    const material = { ...req.body, createdAt: new Date() };
    const result = await db.collection("materials").insertOne(material);
    res.status(201).json({ ...material, _id: result.insertedId });
  } catch (error) {
    next(error);
  }
});

app.patch("/materials/:id", async (req, res, next) => {
  try {
    const db = await getDb();
    const { _id, ...fields } = req.body;
    await db
      .collection("materials")
      .updateOne(
        { _id: new ObjectId(req.params.id) },
        { $set: { ...fields, updatedAt: new Date() } },
      );
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Quotes
// ---------------------------------------------------------------------------

app.get("/quotes", async (_, res, next) => {
  try {
    const db = await getDb();
    res.json(
      await db.collection("quotes").find().sort({ createdAt: -1 }).toArray(),
    );
  } catch (error) {
    next(error);
  }
});

app.post("/quotes", async (req, res, next) => {
  try {
    const db = await getDb();
    const quote = {
      ...req.body,
      code: code("3D"),
      status: req.body.status || "draft",
      createdAt: new Date(),
    };
    const result = await db.collection("quotes").insertOne(quote);
    res.status(201).json({ ...quote, _id: result.insertedId });
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Templates
// ---------------------------------------------------------------------------

app.get("/templates", async (_, res, next) => {
  try {
    const db = await getDb();
    res.json(await db.collection("templates").find().toArray());
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Jobs
// ---------------------------------------------------------------------------

app.get("/jobs", async (_, res, next) => {
  try {
    const db = await getDb();
    res.json(
      await db
        .collection("jobs")
        .find()
        .sort({ priority: -1, dueAt: 1 })
        .toArray(),
    );
  } catch (error) {
    next(error);
  }
});

app.post("/jobs", async (req, res, next) => {
  try {
    const db = await getDb();
    const job = { ...req.body, createdAt: new Date() };
    const result = await db.collection("jobs").insertOne(job);
    res.status(201).json({ ...job, _id: result.insertedId });
  } catch (error) {
    next(error);
  }
});

app.patch("/jobs/:id/status", async (req, res, next) => {
  try {
    const db = await getDb();
    const update = { status: req.body.status, updatedAt: new Date() };
    if (req.body.status === "readyPickup") update.readyAt = new Date();
    if (req.body.status === "printing") update.startedAt = new Date();
    await db
      .collection("jobs")
      .updateOne({ _id: new ObjectId(req.params.id) }, { $set: update });
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Supplies (insumos)
// ---------------------------------------------------------------------------

app.get("/supplies", async (_, res, next) => {
  try {
    const db = await getDb();
    res.json(
      await db.collection("supplies").find().sort({ title: 1 }).toArray(),
    );
  } catch (error) {
    next(error);
  }
});

app.post("/supplies", async (req, res, next) => {
  try {
    const db = await getDb();
    const supply = { ...req.body, createdAt: new Date() };
    const result = await db.collection("supplies").insertOne(supply);
    res.status(201).json({ ...supply, _id: result.insertedId });
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Search & Notifications
// ---------------------------------------------------------------------------

app.get("/search", async (req, res, next) => {
  try {
    const db = await getDb();
    const q = String(req.query.q || "").trim();
    if (!q) return res.json({ orders: [], clients: [], materials: [] });
    const regex = new RegExp(q, "i");
    const [orders, clients, materials] = await Promise.all([
      db
        .collection("customer_orders")
        .find({
          $or: [
            { code: regex },
            { customerName: regex },
            { productTitle: regex },
          ],
        })
        .limit(5)
        .toArray(),
      db
        .collection("clients")
        .find({ $or: [{ name: regex }, { phone: regex }, { channel: regex }] })
        .limit(5)
        .toArray(),
      db
        .collection("materials")
        .find({
          $or: [{ brand: regex }, { material: regex }, { colorName: regex }],
        })
        .limit(5)
        .toArray(),
    ]);
    res.json({ orders, clients, materials });
  } catch (error) {
    next(error);
  }
});

app.get("/notifications", async (_, res, next) => {
  try {
    const db = await getDb();
    const lowMaterials = await db
      .collection("materials")
      .find({ $expr: { $lte: ["$remainingGrams", "$lowStockGrams"] } })
      .limit(20)
      .toArray();
    res.json(
      lowMaterials.map((item) => ({
        _id: item._id,
        title: "Material baixo",
        message: `${item.material} ${item.colorName || ""}`.trim(),
        severity: item.remainingGrams <= 0 ? "danger" : "warning",
        createdAt: item.createdAt || new Date(),
      })),
    );
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Error handler
// ---------------------------------------------------------------------------

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(500).json({ error: error.message || "Internal error" });
});

app.listen(port, () => {
  console.log(`Me Ajuda em 3D API listening on :${port}`);
});
