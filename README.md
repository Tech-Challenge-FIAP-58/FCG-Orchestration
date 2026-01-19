# 🚀 Guia de Execução – Docker Compose e Kubernetes (Minikube)

Este documento descreve como executar o ambiente completo do projeto utilizando **Docker Compose** ou **Kubernetes com Minikube**, considerando usuários de **Windows (PowerShell)**, **Linux** e **Git Bash no Windows**.

> Todos os comandos **iguais entre Windows e Linux** são apresentados **uma única vez**.  
> Quando houver diferença, ela estará explicitamente indicada.

---

## 📁 Estrutura esperada do projeto

```text
/
├─ infra/
│  ├─ docker-compose.yml
│  └─ k8s/
├─ UsersAPI/
├─ CatalogApi/
├─ PaymentsApi/
├─ NotificationsApi/
```

---

## 🐳 Docker Compose

### Pré-requisitos
- Docker instalado
- Docker Compose v2 (`docker compose version`)

### Subir todo o ambiente

```bash
docker compose up --build
```

Ou em segundo plano:

```bash
docker compose up -d --build
```

### Verificar containers

```bash
docker compose ps
```

### Logs de um serviço

```bash
docker compose logs -f user-api
```

### Encerrar o ambiente

```bash
docker compose down
```

---

## ☸️ Kubernetes com Minikube

### 1️⃣ Instalar o Minikube

- Windows: https://minikube.sigs.k8s.io/docs/start/
- Linux: https://minikube.sigs.k8s.io/docs/start/

---

### 2️⃣ Iniciar o Minikube

```bash
minikube start
```

Verificar status:

```bash
minikube status
```

---

### 3️⃣ Direcionar os builds Docker para o Minikube

> Este passo garante que as imagens Docker sejam criadas **dentro do cluster**.

#### Windows (PowerShell)
```powershell
minikube docker-env | Invoke-Expression
```

#### Linux / Git Bash
```bash
eval $(minikube docker-env)
```

---

### 4️⃣ Build das imagens (nomes esperados)

> Execute os comandos **a partir da pasta `infra` ou raiz**, respeitando os caminhos abaixo.

#### User API
```bash
docker build -t user-api:1.0.0 -f ../UsersAPI/src/FCG.Users.WebApi/Dockerfile ../UsersAPI
```

#### Catalog API
```bash
docker build -t catalog-api:1.0.0 -f ../CatalogApi/src/FCG.Catalog.WebApi/Dockerfile ../CatalogApi
```

#### Payments API
```bash
docker build -t payment-api:1.0.0 -f ../PaymentsApi/src/FCG.Payments/Dockerfile ../PaymentsApi
```

#### Notification API
```bash
docker build -t notification-api:1.0.0 -f ../NotificationsApi/src/FCG.Notifications/Dockerfile ../NotificationsApi
```

---

### 5️⃣ Aplicar os manifests Kubernetes (recursivo)

```bash
kubectl apply -R -f k8s/
```

---

### 6️⃣ Verificar se o ambiente está saudável

#### Pods
```bash
kubectl get pods
```

#### Services
```bash
kubectl get services
```

#### Detalhar um Pod (debug)
```bash
kubectl describe pod <nome-do-pod>
```

#### Logs
```bash
kubectl logs <nome-do-pod>
```

---

### 7️⃣ Acesso aos serviços (ClusterIP)

⚠️ **Nenhum serviço está exposto via NodePort**.  
Todos utilizam **ClusterIP**, portanto o acesso externo deve ser feito por **port-forward** ou **tunnel**.

---

#### Opção 1️⃣ – Port Forward (recomendado para testes)

Exemplo para a **User API**:

```bash
kubectl port-forward service/user-api 8080:8080
```

Acesse em:
```
http://localhost:8080
```

> Repita para outros serviços conforme necessário.

---

#### Opção 2️⃣ – Minikube Tunnel (exposição temporária)

```bash
minikube tunnel
```

> Este comando cria rotas de rede para os serviços ClusterIP.  
> Requer privilégios de administrador/root.

#### Opção 3️⃣ - Service do Minikube

```bash 
minikube service <nome-do-service>
```

> Por quê isso funciona?
> - Cria um túnel temporário
> - Usa kubectl port-forward ou
> - Usa um proxy interno do Minikube
> - Não altera o tipo do Service
> - Não cria NodePort

---

## ✅ Observações Importantes

- `minikube stop` **não remove** imagens nem deployments
- Ao reiniciar o terminal, **reaplique o `docker-env`**
- Não é necessário rebuild se as imagens já existirem no Minikube
- Comunicação entre serviços ocorre via **DNS interno do Kubernetes**
  - Ex: `rabbitmq`, `sqlserver`, `user-api`
