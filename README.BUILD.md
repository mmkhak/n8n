# 🏗️ راهنمای Build و دیپلوی n8n از سورس

این راهنما نحوه build و دیپلوی n8n از سورس کد را توضیح می‌دهد.

## 📋 پیش‌نیازها

### برای Build محلی:
- Node.js 22.16 یا بالاتر
- pnpm 10.18.3 یا بالاتر
- حداقل 8GB RAM
- حداقل 10GB فضای دیسک

### برای Docker Build:
- Docker 20.10 یا بالاتر
- Docker Compose 2.0 یا بالاتر
- حداقل 4GB RAM برای build
- حداقل 10GB فضای دیسک

## 🚀 Build محلی

### 1. نصب Dependencies

```bash
# فعال‌سازی pnpm
corepack enable
corepack prepare pnpm@10.18.3 --activate

# نصب dependencies
pnpm install --frozen-lockfile
```

### 2. Build پروژه

```bash
# Build کامل برای deployment
pnpm build:deploy
```

این دستور تمام packages را build می‌کند و فایل‌های لازم را در پوشه `compiled` قرار می‌دهد.

### 3. اجرای محلی

```bash
# اجرای n8n
cd packages/cli/bin
./n8n
```

## 🐳 Build با Docker

### Build Image

```bash
# Build با docker compose
docker compose -f docker-compose.production.yml build

# یا مستقیماً با docker
docker build -t n8n-custom:latest -f Dockerfile .
```

### اجرای Container

```bash
# با docker compose
docker compose -f docker-compose.production.yml up -d

# یا مستقیماً با docker
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -e DB_TYPE=postgresdb \
  -e DB_POSTGRESDB_HOST=your-db-host \
  -v n8n_data:/home/node/.n8n \
  n8n-custom:latest
```

## 🔧 تنظیمات Build

### متغیرهای Build

در `docker-compose.production.yml` می‌توانید این متغیرها را تنظیم کنید:

```yaml
build:
  args:
    - NODE_VERSION=22.21.0        # نسخه Node.js
    - N8N_VERSION=1.118.0          # نسخه n8n
    - N8N_RELEASE_TYPE=stable      # نوع release (stable/dev)
```

### Build Arguments در Docker

```bash
docker build \
  --build-arg NODE_VERSION=22.21.0 \
  --build-arg N8N_VERSION=1.118.0 \
  --build-arg N8N_RELEASE_TYPE=stable \
  -t n8n-custom:latest \
  -f Dockerfile .
```

## 📦 ساختار Build

پروژه در دو مرحله build می‌شود:

### Stage 1: Builder
- نصب dependencies
- کامپایل TypeScript
- Build تمام packages
- ایجاد پوشه `compiled`

### Stage 2: Runtime
- استفاده از base image سبک
- کپی فایل‌های compiled
- نصب native dependencies (sqlite3)
- تنظیم permissions

## 🎯 Build برای Coolify

### مراحل Setup:

1. **Push کد به Git Repository**
```bash
git add .
git commit -m "Add production build config"
git push origin master
```

2. **تنظیم در Coolify**
   - Repository URL: آدرس Git repo خود
   - Branch: `master`
   - Compose File: `docker-compose.production.yml`
   - Build Command: (خالی بگذارید، Docker Compose خودش build می‌کند)

3. **تنظیم Environment Variables**
   - همه متغیرهای `.env.production.example` را کپی کنید
   - کلیدهای امنیتی را تولید کنید
   - دامنه خود را تنظیم کنید

4. **شروع Build**
   - روی "Deploy" کلیک کنید
   - اولین build حدود 10-15 دقیقه طول می‌کشد
   - builds بعدی سریع‌تر هستند (با استفاده از cache)

## ⚡ بهینه‌سازی Build

### استفاده از BuildKit

برای سرعت بیشتر:

```bash
# فعال‌سازی BuildKit
export DOCKER_BUILDKIT=1

# Build با cache
docker build \
  --cache-from=n8n-custom:latest \
  -t n8n-custom:latest \
  -f Dockerfile .
```

### Multi-stage Build Cache

Dockerfile ما از multi-stage build استفاده می‌کند که:
- ✅ Layers را cache می‌کند
- ✅ حجم final image را کم می‌کند
- ✅ زمان build را کاهش می‌دهد

## 🐛 عیب‌یابی Build

### خطای Out of Memory

اگر در build با خطای memory مواجه شدید:

```bash
# افزایش memory برای Docker
# در Docker Desktop: Settings > Resources > Memory > 8GB

# یا با محدودیت memory
docker build --memory=4g -t n8n-custom:latest -f Dockerfile .
```

### خطای pnpm install

```bash
# پاک کردن cache و دوباره تلاش
pnpm store prune
pnpm install --frozen-lockfile --force
```

### Build آهسته

```bash
# استفاده از BuildKit و cache
export DOCKER_BUILDKIT=1
docker build --build-arg BUILDKIT_INLINE_CACHE=1 \
  -t n8n-custom:latest -f Dockerfile .
```

## 📊 زمان‌های Build تقریبی

| مرحله | زمان تقریبی |
|-------|-------------|
| اولین build کامل | 10-15 دقیقه |
| Build با cache | 2-5 دقیقه |
| Build فقط code changes | 1-3 دقیقه |

## 🔄 بروزرسانی

### بروزرسانی به آخرین کد

```bash
# دریافت آخرین تغییرات
git pull origin master

# Rebuild
docker compose -f docker-compose.production.yml build --no-cache
docker compose -f docker-compose.production.yml up -d
```

### بروزرسانی dependencies

```bash
# بروزرسانی pnpm-lock.yaml
pnpm update

# Rebuild
docker compose -f docker-compose.production.yml build --no-cache
```

## 📝 نکات مهم

1. **Cache Layer**: Docker از cache layer استفاده می‌کند، بنابراین تغییرات جزئی build سریع است

2. **Dependencies**: فقط زمانی که `package.json` یا `pnpm-lock.yaml` تغییر کند، dependencies دوباره نصب می‌شود

3. **Build Context**: `.dockerignore` فایل‌های غیرضروری را از build context حذف می‌کند

4. **Multi-platform**: اگر نیاز به build برای ARM64 دارید:
   ```bash
   docker buildx build --platform linux/amd64,linux/arm64 \
     -t n8n-custom:latest -f Dockerfile .
   ```

## 🆘 پشتیبانی

اگر با مشکلی مواجه شدید:

1. لاگ‌های build را بررسی کنید
2. از آخرین نسخه Node.js و pnpm استفاده کنید
3. cache Docker را پاک کنید: `docker builder prune -a`
4. به [مستندات n8n](https://docs.n8n.io/) مراجعه کنید

## 🔗 منابع مفید

- [N8N Documentation](https://docs.n8n.io/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [pnpm Documentation](https://pnpm.io/)
