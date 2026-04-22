<!-- @format -->

# Me Ajuda em 3D — API

Backend Node.js + Express + MongoDB para o app Flutter de gestao de impressao 3D.

## Setup local

```bash
cp .env.example .env
# Edite .env com sua MONGODB_URI
npm install
npm run dev
```

## Deploy no Railway

1. Crie um novo projeto no [railway.app](https://railway.app)
2. Conecte este repositorio
3. Configure as variaveis de ambiente:
   - `MONGODB_URI` — connection string do MongoDB Atlas
   - `MONGODB_DB` — nome do banco (padrao: `me_ajuda_em_3d`)
   - `PORT` — porta (Railway define automaticamente)
   - `PUBLIC_BASE_URL` — URL publica gerada pelo Railway
4. Deploy automatico a cada push

## Endpoints

### Rota publica (cliente)

| Metodo | Rota                         | Descricao                  |
| ------ | ---------------------------- | -------------------------- |
| GET    | `/customer-products`         | Lista produtos base        |
| POST   | `/customer-orders`           | Cria pedido                |
| GET    | `/customer-orders?email=...` | Consulta pedidos por email |

### Admin

| Metodo | Rota                          | Descricao                     |
| ------ | ----------------------------- | ----------------------------- |
| GET    | `/dashboard`                  | Resumo geral                  |
| GET    | `/clients`                    | Lista clientes                |
| POST   | `/clients`                    | Cria cliente                  |
| GET    | `/materials`                  | Lista materiais               |
| POST   | `/materials`                  | Cria material                 |
| PATCH  | `/materials/:id`              | Atualiza material             |
| GET    | `/supplies`                   | Lista insumos                 |
| POST   | `/supplies`                   | Cria insumo                   |
| GET    | `/quotes`                     | Lista orcamentos              |
| POST   | `/quotes`                     | Cria orcamento                |
| GET    | `/templates`                  | Lista templates               |
| GET    | `/jobs`                       | Lista jobs                    |
| POST   | `/jobs`                       | Cria job                      |
| PATCH  | `/jobs/:id/status`            | Atualiza status do job        |
| PATCH  | `/customer-orders/:id/status` | Atualiza status do pedido     |
| GET    | `/search?q=...`               | Busca global                  |
| GET    | `/notifications`              | Alertas de estoque            |
| POST   | `/uploads`                    | Upload de arquivo (multipart) |
| GET    | `/health`                     | Health check                  |

## Collections MongoDB

- `customer_orders` — pedidos de clientes
- `clients` — cadastro de clientes
- `materials` — filamentos e materiais
- `supplies` — insumos (argolas, imas, embalagens)
- `quotes` — orcamentos
- `templates` — templates de orcamento
- `jobs` — jobs de producao
- `uploads` — metadados de arquivos

## Conexao com o Flutter

O app Flutter usa `ApiOperationRepository` que aponta pra esta API.
Configure a URL via `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=https://sua-api.up.railway.app
```
