# 🎯 خلاصه تغییرات برای دیپلوی n8n از سورس روی Coolify

## 📝 فایل‌های ایجاد شده:

### 1. ✅ `Dockerfile` (در ریشه پروژه)
- یک Dockerfile کامل برای build پروژه از سورس
- شامل دو stage: Builder و Runtime
- بهینه شده برای استفاده در production

### 2. ✅ `docker-compose.production.yml`
- کانفیگ Docker Compose برای production
- به جای استفاده از image آماده، پروژه را build می‌کند
- شامل PostgreSQL به عنوان دیتابیس
- تنظیمات امنیتی و performance

### 3. ✅ `.env.production.example`
- نمونه فایل environment variables
- شامل تمام تنظیمات مورد نیاز
- راهنمای کامل برای هر متغیر

### 4. ✅ `COOLIFY_DEPLOYMENT.md`
- راهنمای کامل فارسی برای دیپلوی روی Coolify
- مراحل گام‌به‌گام
- نکات امنیتی
- راهنمای عیب‌یابی

### 5. ✅ `README.BUILD.md`
- راهنمای جامع build و دیپلوی
- توضیح مراحل build
- بهینه‌سازی‌ها
- عیب‌یابی مشکلات رایج

### 6. ✅ `build.sh`
- اسکریپت کمکی برای build محلی
- Executable و آماده استفاده

### 7. ✅ `test-build.sh`
- اسکریپت تست build قبل از دیپلوی
- بررسی prerequisites
- اجرای خودکار

## 🚀 مراحل استفاده:

### گام 1: آماده‌سازی محلی

```bash
# کپی فایل environment
cp .env.production.example .env.production

# ویرایش و تنظیم متغیرها
nano .env.production
```

### گام 2: تولید کلیدهای امنیتی

```bash
# تولید N8N_ENCRYPTION_KEY
openssl rand -hex 32

# تولید N8N_USER_MANAGEMENT_JWT_SECRET
openssl rand -hex 32
```

### گام 3: تست محلی (اختیاری)

```bash
./test-build.sh
```

### گام 4: Push به Git

```bash
git add .
git commit -m "Add production deployment config"
git push origin master
```

### گام 5: دیپلوی در Coolify

1. ایجاد پروژه جدید در Coolify
2. اضافه کردن Resource از نوع "Docker Compose"
3. اتصال به Git Repository
4. تنظیم:
   - Compose File: `docker-compose.production.yml`
   - Branch: `master`
5. اضافه کردن Environment Variables از `.env.production`
6. تنظیم Domain و SSL
7. کلیک روی "Deploy"

## ⚙️ تنظیمات مهم:

### Build Arguments (در docker-compose.yml)
```yaml
build:
  args:
    - NODE_VERSION=22.21.0
    - N8N_VERSION=1.118.0
    - N8N_RELEASE_TYPE=stable
```

### Environment Variables ضروری
```env
POSTGRES_PASSWORD=پسورد_قوی
N8N_ENCRYPTION_KEY=کلید_32_کاراکتری
N8N_USER_MANAGEMENT_JWT_SECRET=کلید_32_کاراکتری_دیگر
N8N_HOST=your-domain.com
N8N_EDITOR_BASE_URL=https://your-domain.com
WEBHOOK_URL=https://your-domain.com
```

## ⏱️ زمان‌بندی:

- **اولین Build**: 10-15 دقیقه
- **Build با Cache**: 2-5 دقیقه
- **Build فقط Code Changes**: 1-3 دقیقه

## 💾 نیازمندی‌های سیستم:

### برای Build:
- حداقل 4GB RAM
- حداقل 10GB فضای دیسک
- Docker 20.10+

### برای اجرا:
- حداقل 2GB RAM
- حداقل 5GB فضای دیسک

## 🔐 نکات امنیتی:

1. ✅ هرگز از کلیدهای پیش‌فرض استفاده نکنید
2. ✅ پسورد دیتابیس را قوی انتخاب کنید
3. ✅ حتماً HTTPS فعال کنید
4. ✅ منظم backup بگیرید
5. ✅ فایل `.env.production` را در `.gitignore` قرار دهید

## 🎨 مزایای این روش:

- ✅ Build از سورس کد شما
- ✅ قابلیت customize کامل
- ✅ آخرین تغییرات شما اعمال می‌شود
- ✅ بهینه برای development و production
- ✅ استفاده از Docker multi-stage build
- ✅ Cache layer برای سرعت بیشتر

## 🐛 عیب‌یابی سریع:

### Build fail می‌شود؟
```bash
# پاک کردن cache
docker builder prune -a

# Build دوباره با no-cache
docker compose -f docker-compose.production.yml build --no-cache
```

### Container start نمی‌شود؟
```bash
# بررسی لاگ‌ها
docker compose -f docker-compose.production.yml logs n8n

# بررسی health
docker compose -f docker-compose.production.yml ps
```

### خطای Database Connection؟
```bash
# بررسی PostgreSQL
docker compose -f docker-compose.production.yml logs postgres

# تست connection
docker compose -f docker-compose.production.yml exec postgres pg_isready
```

## 📚 منابع:

- `COOLIFY_DEPLOYMENT.md` - راهنمای کامل دیپلوی
- `README.BUILD.md` - راهنمای جامع build
- `.env.production.example` - نمونه تنظیمات

## 🆘 نیاز به کمک؟

1. راهنمای `COOLIFY_DEPLOYMENT.md` را مطالعه کنید
2. بخش Troubleshooting را چک کنید
3. لاگ‌های Docker را بررسی کنید
4. مستندات n8n را مطالعه کنید

---

✨ **موفق باشید!** ✨
