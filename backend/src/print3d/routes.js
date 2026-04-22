/** @format */

const router = require("express").Router();
const { ObjectId } = require("mongodb");
const multer = require("multer");
const { getDb } = require("./db");

const upload = multer({ dest: "uploads/" });

function code(prefix) {
  return `${prefix}-${Date.now().toString().slice(-6)}`;
}

// ---------------------------------------------------------------------------
// Catalog (protegido — admin)
// ---------------------------------------------------------------------------

router.post("/catalog", async (req, res, next) => {
  try {
    const db = await getDb();
    const now = new Date();
    const item = {
      categoryId: req.body.categoryId,
      title: req.body.title,
      description: req.body.description || "",
      style: req.body.style || "",
      priceCents: Number(req.body.priceCents),
      imageTag: req.body.imageTag || "",
      createdAt: now,
      updatedAt: now,
    };
    const result = await db.collection("catalog_items").insertOne(item);
    res.status(201).json({ ...item, _id: result.insertedId });
  } catch (error) {
    next(error);
  }
});

router.put("/catalog/:id", async (req, res, next) => {
  try {
    const db = await getDb();
    const { _id, ...fields } = req.body;
    const result = await db
      .collection("catalog_items")
      .findOneAndUpdate(
        { _id: new ObjectId(req.params.id) },
        { $set: { ...fields, updatedAt: new Date() } },
        { returnDocument: "after" },
      );
    if (!result) return res.status(404).json({ error: "Item nao encontrado" });
    res.json(result);
  } catch (error) {
    next(error);
  }
});

router.delete("/catalog/:id", async (req, res, next) => {
  try {
    const db = await getDb();
    await db
      .collection("catalog_items")
      .deleteOne({ _id: new ObjectId(req.params.id) });
    res.status(204).end();
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Dashboard (protegido)
// ---------------------------------------------------------------------------

router.get("/dashboard", async (_req, res, next) => {
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
// Clients (protegido)
// ---------------------------------------------------------------------------

router.get("/clients", async (_req, res, next) => {
  try {
    const db = await getDb();
    res.json(
      await db.collection("clients").find().sort({ createdAt: -1 }).toArray(),
    );
  } catch (error) {
    next(error);
  }
});

router.post("/clients", async (req, res, next) => {
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
// Materials (protegido)
// ---------------------------------------------------------------------------

router.get("/materials", async (_req, res, next) => {
  try {
    const db = await getDb();
    res.json(
      await db.collection("materials").find().sort({ createdAt: -1 }).toArray(),
    );
  } catch (error) {
    next(error);
  }
});

router.post("/materials", async (req, res, next) => {
  try {
    const db = await getDb();
    const material = { ...req.body, createdAt: new Date() };
    const result = await db.collection("materials").insertOne(material);
    res.status(201).json({ ...material, _id: result.insertedId });
  } catch (error) {
    next(error);
  }
});

router.patch("/materials/:id", async (req, res, next) => {
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
// Quotes (protegido)
// ---------------------------------------------------------------------------

router.get("/quotes", async (_req, res, next) => {
  try {
    const db = await getDb();
    res.json(
      await db.collection("quotes").find().sort({ createdAt: -1 }).toArray(),
    );
  } catch (error) {
    next(error);
  }
});

router.post("/quotes", async (req, res, next) => {
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
// Templates (protegido)
// ---------------------------------------------------------------------------

router.get("/templates", async (_req, res, next) => {
  try {
    const db = await getDb();
    res.json(await db.collection("templates").find().toArray());
  } catch (error) {
    next(error);
  }
});

// ---------------------------------------------------------------------------
// Jobs (protegido)
// ---------------------------------------------------------------------------

router.get("/jobs", async (_req, res, next) => {
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

router.post("/jobs", async (req, res, next) => {
  try {
    const db = await getDb();
    const job = { ...req.body, createdAt: new Date() };
    const result = await db.collection("jobs").insertOne(job);
    res.status(201).json({ ...job, _id: result.insertedId });
  } catch (error) {
    next(error);
  }
});

router.patch("/jobs/:id/status", async (req, res, next) => {
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
// Supplies (protegido)
// ---------------------------------------------------------------------------

router.get("/supplies", async (_req, res, next) => {
  try {
    const db = await getDb();
    res.json(
      await db.collection("supplies").find().sort({ title: 1 }).toArray(),
    );
  } catch (error) {
    next(error);
  }
});

router.post("/supplies", async (req, res, next) => {
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
// Search & Notifications (protegido)
// ---------------------------------------------------------------------------

router.get("/search", async (req, res, next) => {
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

router.get("/notifications", async (_req, res, next) => {
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
// Uploads (protegido)
// ---------------------------------------------------------------------------

router.post("/uploads", upload.single("file"), async (req, res, next) => {
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

module.exports = router;
