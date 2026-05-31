# 📡 API Endpoints

## 🔐 Auth (`/api/auth`)

| Méthode | Endpoint | Protection | Description |
|---------|----------|------------|-------------|
| `POST` | `/api/auth/register` | Public | Inscription |
| `POST` | `/api/auth/login` | Public | Connexion |
| `GET` | `/api/auth/me` | JWT | Profil |
| `GET` | `/api/auth/health` | Public | Health check |

## 📦 Products (`/api/products`)

| Méthode | Endpoint | Protection | Description |
|---------|----------|------------|-------------|
| `GET` | `/api/products` | Public | Liste produits |
| `GET` | `/api/products/search?q=...` | Public | Recherche |
| `GET` | `/api/products/category/:cat` | Public | Par catégorie |
| `GET` | `/api/products/:id` | Public | Détails |
| `POST` | `/api/products` | Admin | Créer |
| `PUT` | `/api/products/:id` | Admin | Modifier |
| `DELETE` | `/api/products/:id` | Admin | Supprimer |

## 🛒 Orders (`/api/orders`)

| Méthode | Endpoint | Protection | Description |
|---------|----------|------------|-------------|
| `GET` | `/api/orders` | JWT | Mes commandes |
| `GET` | `/api/orders/all` | Admin | Toutes commandes |
| `GET` | `/api/orders/:id` | JWT/Admin | Détails |
| `POST` | `/api/orders` | JWT | Créer |
| `PUT` | `/api/orders/:id/status` | Admin | Changer statut |

## ⭐ Reviews (`/api/reviews`)

| Méthode | Endpoint | Protection | Description |
|---------|----------|------------|-------------|
| `GET` | `/api/reviews/product/:id` | Public | Avis produit |
| `GET` | `/api/reviews` | Admin | Tous avis |
| `POST` | `/api/reviews` | JWT | Créer |
| `PUT` | `/api/reviews/:id` | JWT/Admin | Modifier |
| `DELETE` | `/api/reviews/:id` | JWT/Admin | Supprimer |
