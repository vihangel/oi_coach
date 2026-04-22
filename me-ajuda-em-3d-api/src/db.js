/** @format */

import { MongoClient } from "mongodb";

let client;
let database;

export async function getDb() {
  if (database) return database;

  const uri = process.env.MONGODB_URI;
  const dbName = process.env.MONGODB_DB || "me_ajuda_em_3d";
  if (!uri) {
    throw new Error("MONGODB_URI is required");
  }

  client = new MongoClient(uri);
  await client.connect();
  database = client.db(dbName);

  await Promise.all([
    database
      .collection("customer_orders")
      .createIndex({ email: 1, createdAt: -1 }),
    database
      .collection("clients")
      .createIndex({ name: "text", phone: "text", channel: "text" }),
    database
      .collection("materials")
      .createIndex({ brand: "text", material: "text", colorName: "text" }),
    database.collection("uploads").createIndex({ orderId: 1 }),
    database.collection("quotes").createIndex({ status: 1, createdAt: -1 }),
    database
      .collection("jobs")
      .createIndex({ status: 1, priority: -1, dueAt: 1 }),
    database.collection("supplies").createIndex({ title: 1 }),
  ]);

  return database;
}
