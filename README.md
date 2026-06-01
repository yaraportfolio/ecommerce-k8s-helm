# ⎈ Helm Chart — Microservices E-Commerce Kubernetes

![Helm](https://img.shields.io/badge/Helm-3.x-0F1689?logo=helm&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.23+-326CE5?logo=kubernetes&logoColor=white)
![GHCR](https://img.shields.io/badge/GHCR-GitHub_Registry-24292e?logo=github&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-ServiceMonitor-E6522C?logo=prometheus&logoColor=white)
![Version](https://img.shields.io/badge/chart-v3.0-blue)

Helm Chart complet pour déployer les 4 microservices e-commerce sur Kubernetes — utilise GitHub Container Registry (GHCR), autoscaling HPA, monitoring Prometheus et rollback granulaire par service.

> 💡 **Objectif Portfolio** : Illustrer la gestion de configuration Kubernetes via Helm — déploiement déclaratif, mises à jour ciblées par service, rollback en une commande, et séparation secrets/configuration.

---

## 🗺️ Architecture Déployée

```
┌─────────────────────────────────────────────────────────┐
│             Frontend VM (192.168.56.114)                │
│           NGINX → proxy vers Ingress :30080             │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│         Kubernetes Cluster (192.168.56.111)             │
│                                                         │← Nous sommes ici (projet actuel)
│  ┌─────────────────────────────────────────────────┐    │
│  │          NGINX Ingress (NodePort 30080)         │    │
│  │               api.ecommerce.local               │    │
│  └────┬────────────┬────────────┬────────────┬─────┘    │
│       │            │            │            │          │
│  ┌────▼────┐  ┌────▼────┐  ┌────▼────┐  ┌────▼────┐     │
│  │  Auth   │  │ Product │  │  Order  │  │ Review  │     │
│  │  :3001  │  │  :3002  │  │  :3003  │  │  :3004  │     │
│  │   HPA   │  │   HPA   │  │   HPA   │  │   HPA   │     │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘     │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│  Database VM (192.168.56.115) — MariaDB 10.11 externe   │
└─────────────────────────────────────────────────────────┘
```

<details>
  <summary>🖼️ <code>Architecture Applicative</code></summary>

![Architecture Applicative](https://raw.githubusercontent.com/yaraportfolio/ecommerce-frontend/main/.img/Architecture-Applicative.png)

</details>

<details>
  <summary>🏗️ <code>Architecture Infrastructure</code></summary>

![Architecture Infrastructure](https://raw.githubusercontent.com/yaraportfolio/ecommerce-frontend/main/.img/Architecture-Infrastructure.png)

</details>

<details>
  <summary>☸️ <code>Vue Kubernetes (Lens)</code></summary>

![Lens](https://raw.githubusercontent.com/yaraportfolio/ecommerce-frontend/main/.img/lens.png)

</details>

---

## ⚖️ Comparaison des Architectures

| Critère | **Kubernetes + Helm** | Docker Swarm | Monolithe |
|---------|:---------------------:|:------------:|:---------:|
| **Déploiement** | Helm (déclaratif) | Docker Stack | PM2 / Docker |
| **Complexité DevOps** | Élevée | Moyenne | Faible |
| **Auto-healing** | ✅ Probes | ✅ Redémarrage | ⚠️ PM2 only |
| **Scalabilité** | ✅ HPA automatique | ✅ Manuelle | Verticale |
| **Rolling Update** | ✅ Zero-downtime | ✅ | Manuel |
| **Rollback** | ✅ `helm rollback` | ❌ | Manuel |
| **Monitoring** | ✅ Prometheus/Grafana | Portainer | PM2 monit |
| **Port d'entrée** | 30080 (NodePort) | 8000 (Kong) | 3000 |
| **Quand l'utiliser** | Prod complexe, SRE | Prod simple | Dev, petite prod |

---

## 📦 Services

| Service | Port | Rôle | HPA | Image GHCR |
|---------|:----:|------|:---:|-----------------|
| **auth-service** | 3001 | Authentification JWT | ✅ | `ghcr.io/yaraportfolio/auth-service` |
| **product-service** | 3002 | Catalogue produits | ✅ | `ghcr.io/yaraportfolio/product-service` |
| **order-service** | 3003 | Gestion commandes | ✅ | `ghcr.io/yaraportfolio/order-service` |
| **review-service** | 3004 | Avis produits | ✅ | `ghcr.io/yaraportfolio/review-service` |

---

## 📋 Prérequis

| Outil | Version | Vérification |
|-------|---------|-------------|
| Kubernetes | 1.23+ | `kubectl version` |
| Helm | 3.x | `helm version` |
| NGINX Ingress | — | `kubectl get pods -n ingress-nginx` |
| Metrics Server | — | `kubectl get deployment metrics-server -n kube-system` |
| Prometheus Operator | Optionnel | `kubectl get crd servicemonitors.monitoring.coreos.com` |

> **Configuration on-premise :** L'Ingress Controller est exposé via NodePort **30080**. C'est cet endpoint qui doit être utilisé pour l'accès externe depuis le frontend.

```bash
# Vérifier tous les prérequis d'un coup
kubectl version && helm version
kubectl get pods -n ingress-nginx
kubectl get deployment metrics-server -n kube-system
```

---

## ⚡ Quick Start

```bash
git clone https://github.com/yaraportfolio/ecommerce-k8s-helm.git
cd ecommerce-k8s-helm

# Copier et éditer les secrets
cp values-secrets.yaml.example values-secrets.yaml
nano values-secrets.yaml

# Installer (GHCR public — GitHub Container Registry)
helm install ecommerce-microservices . \
  --create-namespace \
  --namespace ecommerce \
  -f values-secrets.yaml

# Vérifier
kubectl get pods -n ecommerce
# ✅ 8 pods Running (2 replicas × 4 services)
```

---

## 🔄 Configuration Registry

### GitHub Container Registry (GHCR) Public ✅

```yaml
# values.yaml
image:
  registryType: ghcr
  ghcr:
    registry: ghcr.io
    owner: yaraportfolio
  imagePullSecrets:
    enabled: false   # Images publiques — pas de secret requis
```

Images : 
- `ghcr.io/yaraportfolio/auth-service:v3.3`
- `ghcr.io/yaraportfolio/product-service:v3.3`
- `ghcr.io/yaraportfolio/order-service:v3.3`
- `ghcr.io/yaraportfolio/review-service:v3.3`

```bash
helm install ecommerce-microservices . \
  --create-namespace --namespace ecommerce \
  -f values-secrets.yaml
```

Les images sont **publiques** sur GitHub Container Registry, pas d'authentification requise.

---

## 🎯 Mises à Jour Ciblées

### Mettre à Jour UN Seul Service

```bash
# auth-service v3.2 → v3.3 (les 3 autres restent inchangés)
helm upgrade ecommerce-microservices . \
  --reuse-values \
  --set services.authService.image.tag=v3.3
```

### Mettre à Jour Plusieurs Services

```bash
helm upgrade ecommerce-microservices . \
  --reuse-values \
  --set services.authService.image.tag=v3.3 \
  --set services.productService.image.tag=v3.2
```

### Activer / Désactiver un Service

```bash
# Désactiver temporairement review-service
helm upgrade ecommerce-microservices . \
  --reuse-values \
  --set services.reviewService.enabled=false
```

---

## 🔙 Rollback

```bash
# Voir l'historique des révisions
helm history ecommerce-microservices -n ecommerce

# Rollback à la révision précédente
helm rollback ecommerce-microservices -n ecommerce

# Rollback à une révision spécifique
helm rollback ecommerce-microservices 3 -n ecommerce

# Vérifier après rollback
kubectl get pods -n ecommerce
kubectl rollout status deployment/auth-service -n ecommerce
```

---

## 📈 Autoscaling HPA

```yaml
# values.yaml — Activer pour un service
services:
  authService:
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 10
      targetCPUUtilizationPercentage: 70
      targetMemoryUtilizationPercentage: 80
```

```bash
# Activer via CLI
helm upgrade ecommerce-microservices . \
  --reuse-values \
  --set services.authService.autoscaling.enabled=true

# Vérifier
kubectl get hpa -n ecommerce
```

---

## 📊 Monitoring Prometheus

### Activer les ServiceMonitors

```yaml
# values.yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    labels:
      prometheus: kube-prometheus
```

### Métriques Exposées

Chaque service expose `/metrics` :

```
# Node.js runtime
nodejs_heap_size_total_bytes
nodejs_heap_used_bytes
process_cpu_seconds_total

# HTTP
http_requests_total{method, route, status_code}
http_request_duration_seconds{quantile}
http_request_errors_total
```

### Requêtes PromQL Utiles

```promql
# Requêtes par seconde par service
rate(http_requests_total[5m])

# Latence P95
histogram_quantile(0.95,
  rate(http_request_duration_seconds_bucket[5m])
)

# Taux d'erreur
rate(http_request_errors_total[5m])
  / rate(http_requests_total[5m])

# Usage mémoire heap par pod
nodejs_heap_used_bytes / nodejs_heap_size_total_bytes * 100
```

---

## 🔍 Commandes de Vérification

```bash
# Status du déploiement Helm
helm status ecommerce-microservices -n ecommerce

# Tous les pods
kubectl get pods -n ecommerce

# Services et ports
kubectl get svc -n ecommerce

# Ingress
kubectl get ingress -n ecommerce
kubectl describe ingress -n ecommerce

# Logs d'un service
kubectl logs -n ecommerce -l app=auth-service --tail=50

# Tester via Ingress
curl http://192.168.56.111:30080/api/products
curl http://192.168.56.111:30080/api/auth/health

# HPA status
kubectl get hpa -n ecommerce

# ServiceMonitor (si Prometheus activé)
kubectl get servicemonitor -n ecommerce
```

---

## ✅ Checklist Déploiement

### Avant Installation

- [ ] `kubectl version` — Cluster accessible
- [ ] `helm version` — Helm 3.x installé
- [ ] NGINX Ingress déployé
- [ ] MariaDB accessible depuis le cluster (`192.168.56.115:3306`)
- [ ] Images disponibles sur registry choisi
- [ ] `values-secrets.yaml` co++++++++nfiguré (DB password, JWT secret)
- [ ] Metrics Server déployé (si HPA activé)

### Après Installation

- [ ] `helm status ecommerce-microservices` → deployed
- [ ] `kubectl get pods -n ecommerce` → 8/8 Running
- [ ] `curl http://192.168.56.111:30080/api/products` → 200 OK
- [ ] Logs sans erreurs de connexion BD
- [ ] `kubectl get hpa -n ecommerce` (si HPA activé)
- [ ] Prometheus scrape OK (si monitoring activé)

---

## 🗑️ Désinstaller

```bash
helm uninstall ecommerce-microservices -n ecommerce

# Supprimer aussi le namespace
kubectl delete namespace ecommerce
```

---

## 🔗 Projets Liés

| Composant | Repository |
|-----------|------------|
| 🔐 Auth Service | [auth-service](https://github.com/yaraportfolio/ecommerce-auth-service) |
| 📦 Product Service | [product-service](https://github.com/yaraportfolio/ecommerce-product-service) |
| 🛒 Order Service | [order-service](https://github.com/yaraportfolio/ecommerce-order-service) |
| ⭐ Review Service | [review-service](https://gitlab.com/yara_portfolio/devops/ecommerce/microservice/review-service) |
| 🎨 Frontend React | [ecommerce-frontend](https://gitlab.com/yara_portfolio/devops/ecommerce/ecommerce-frontend) |

---

## 🎥 Démos

| Sujet | Lien |
|-------|------|
| Déploiement Traditionnel & Docker Compose | *(bientôt disponible)* | 
| Docker Swarm & Kubernetes | *(bientôt disponible)* | ← Regardez cette video
| Monitoring Prometheus / Grafana | *(bientôt disponible)* |

---

## 👨‍💻 Auteur

**Yara Mahi Mohamed**  
Portfolio DevOps & SRE — Architecture Microservices  

Ce projet fait partie d'un portfolio complet démontrant :
- Infrastructure as Code (Ansible)
- Conteneurisation & Orchestration (Docker, Swarm, Kubernetes)
- GitOps & CI/CD (GitLab CI, Jenkins, Semaphore UI)
- Monitoring (Prometheus, Grafana, Loki)
- Architecture Microservices (Docker Stack, Helm)

*⭐ N'oubliez pas de star ce repo si vous le trouvez utile !*
