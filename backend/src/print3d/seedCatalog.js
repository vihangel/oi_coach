/** @format */

require("dotenv").config({
  path: require("path").join(__dirname, "../../.env"),
});
const { getDb } = require("./db");

const items = [
  // Chaveiros
  {
    categoryId: "cat_keyring",
    title: "Chaveiro com nome",
    description: "Nome em relevo, ate 10 letras.",
    style: "Moderno",
    priceCents: 1490,
    imageTag: "key_name",
  },
  {
    categoryId: "cat_keyring",
    title: "Chaveiro com logo",
    description: "Logo da empresa ou time.",
    style: "Corporativo",
    priceCents: 1890,
    imageTag: "key_logo",
  },
  {
    categoryId: "cat_keyring",
    title: "Chaveiro personagem",
    description: "Personagem simples estilizado.",
    style: "Divertido",
    priceCents: 2290,
    imageTag: "key_char",
  },
  // Miniaturas
  {
    categoryId: "cat_miniature",
    title: "Miniatura de personagem",
    description: "Boneco ate 15cm de altura.",
    style: "Detalhado",
    priceCents: 5990,
    imageTag: "mini_char",
  },
  {
    categoryId: "cat_miniature",
    title: "Peca de RPG/tabuleiro",
    description: "Miniaturas para jogos.",
    style: "Fantasia",
    priceCents: 3490,
    imageTag: "mini_rpg",
  },
  // Decoracao
  {
    categoryId: "cat_decor",
    title: "Vaso geometrico",
    description: "Vaso decorativo low-poly.",
    style: "Geometrico",
    priceCents: 4990,
    imageTag: "decor_vase",
  },
  {
    categoryId: "cat_decor",
    title: "Porta-retrato 3D",
    description: "Moldura com relevo tematico.",
    style: "Classico",
    priceCents: 3990,
    imageTag: "decor_frame",
  },
  // Placas e letreiros
  {
    categoryId: "cat_sign",
    title: "Letreiro de parede",
    description: "Nome ou frase em relevo.",
    style: "Moderno",
    priceCents: 6990,
    imageTag: "sign_wall",
  },
  {
    categoryId: "cat_sign",
    title: "Placa de porta",
    description: "Placa com nome e icone.",
    style: "Minimalista",
    priceCents: 3990,
    imageTag: "sign_door",
  },
  // Luminarias
  {
    categoryId: "cat_lamp",
    title: "Luminaria litofane",
    description: "Foto impressa em luz.",
    style: "Personalizado",
    priceCents: 7990,
    imageTag: "lamp_litho",
  },
  {
    categoryId: "cat_lamp",
    title: "Abajur geometrico",
    description: "Abajur com padrao vazado.",
    style: "Geometrico",
    priceCents: 5990,
    imageTag: "lamp_geo",
  },
];

async function seed() {
  const db = await getDb();
  const now = new Date();
  const docs = items.map((item) => ({
    ...item,
    createdAt: now,
    updatedAt: now,
  }));

  await db.collection("catalog_items").deleteMany({});
  await db.collection("catalog_items").insertMany(docs);
  console.log(`${docs.length} catalog items seeded.`);
  process.exit(0);
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});
