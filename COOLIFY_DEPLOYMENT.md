# راهنمای دیپلوی n8n روی Coolify

این راهنما مراحل دیپلوی n8n روی Coolify را شرح می‌دهد.

## پیش‌نیازها

- یک سرور با Coolify نصب شده
- دسترسی به پنل Coolify
- یک دامنه یا ساب‌دامین (اختیاری اما توصیه می‌شود)

## مراحل نصب

### 1. آماده‌سازی Environment Variables

قبل از شروع، باید کلیدهای امنیتی تصادفی تولید کنید:

```bash
# تولید کلید رمزنگاری
openssl rand -hex 32

# تولید JWT Secret (یک کلید دیگر تولید کنید)
openssl rand -hex 32
```

### 2. ایجاد پروژه جدید در Coolify

1. وارد پنل Coolify شوید
2. روی **"New Project"** کلیک کنید
3. یک نام برای پروژه انتخاب کنید (مثلاً `n8n`)

### 3. اضافه کردن Resource

**استفاده از Docker Compose (Build از سورس):**

1. در پروژه، روی **"Add Resource"** کلیک کنید
2. **"Docker Compose"** را انتخاب کنید
3. **"From Git"** را انتخاب کنید (توصیه می‌شود)

**تنظیمات Git Repository:**
- Repository URL: آدرس ریپازیتوری خود
- Branch: `master` یا برنچ مورد نظر
- Compose File Path: `docker-compose.production.yml`
- Build Context: `.` (ریشه پروژه)

**⚠️ توجه مهم:** این روش خود پروژه را از سورس build می‌کند، بنابراین:
- زمان build اولیه حدود 10-15 دقیقه طول می‌کشد
- نیاز به حداقل 4GB RAM برای build دارید
- حداقل 10GB فضای دیسک نیاز است

### 4. تنظیم Environment Variables

در بخش Environment Variables، متغیرهای زیر را اضافه کنید:

#### متغیرهای ضروری:

```env
# Database
POSTGRES_USER=n8n
POSTGRES_PASSWORD=پسورد_قوی_خود_را_اینجا_بگذارید
POSTGRES_DB=n8n

# Domain Configuration
N8N_PROTOCOL=https
N8N_HOST=your-domain.com
N8N_EDITOR_BASE_URL=https://your-domain.com
WEBHOOK_URL=https://your-domain.com

# Security (از کلیدهای تولید شده استفاده کنید)
N8N_ENCRYPTION_KEY=کلید_32_کاراکتری_از_مرحله_1
N8N_USER_MANAGEMENT_JWT_SECRET=کلید_32_کاراکتری_دیگر_از_مرحله_1

# Timezone
TIMEZONE=Asia/Tehran
```

#### متغیرهای اختیاری (برای ایمیل):

```env
N8N_EMAIL_MODE=smtp
N8N_SMTP_HOST=smtp.gmail.com
N8N_SMTP_PORT=587
N8N_SMTP_USER=your-email@gmail.com
N8N_SMTP_PASS=your-app-password
N8N_SMTP_SENDER=your-email@gmail.com
```

### 5. تنظیم Domain

1. در تب **"Domains"** کلیک کنید
2. دامنه یا ساب‌دامین خود را اضافه کنید (مثلاً `n8n.yourdomain.com`)
3. گزینه **"Generate SSL Certificate"** را فعال کنید (Let's Encrypt)
4. گزینه **"Force HTTPS"** را فعال کنید

### 6. تنظیم Volumes (ذخیره‌سازی داده)

اطمینان حاصل کنید که volumes زیر تنظیم شده‌اند:

- `n8n_data` → `/home/node/.n8n`
- `n8n_files` → `/files`
- `postgres_data` → `/var/lib/postgresql/data`

### 7. شروع دیپلوی

1. روی دکمه **"Deploy"** کلیک کنید
2. منتظر بمانید تا عملیات دیپلوی تکمیل شود
3. لاگ‌ها را چک کنید تا مطمئن شوید همه چیز بدون خطا اجرا شده

### 8. دسترسی به n8n

پس از دیپلوی موفق:

1. به دامین خود بروید (مثلاً `https://n8n.yourdomain.com`)
2. اولین بار که وارد می‌شوید، باید یک حساب کاربری ادمین بسازید
3. ایمیل و پسورد خود را وارد کنید

## توجهات امنیتی

### 1. کلیدهای امنیتی

- **هرگز** از کلیدهای پیش‌فرض استفاده نکنید
- کلیدهای تصادفی و قوی (حداقل 32 کاراکتر) تولید کنید
- این کلیدها را در جای امنی نگهداری کنید

### 2. Database

- از پسورد قوی برای PostgreSQL استفاده کنید
- دسترسی به دیتابیس را فقط از داخل شبکه Docker محدود کنید

### 3. HTTPS

- **حتماً** از HTTPS استفاده کنید
- Let's Encrypt را در Coolify فعال کنید

### 4. Backup

منظم backup بگیرید:

```bash
# Backup PostgreSQL
docker exec -t n8n-postgres pg_dump -U n8n n8n > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup n8n data
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n_data_backup.tar.gz /data
```

## عیب‌یابی (Troubleshooting)

### n8n شروع نمی‌شود

1. لاگ‌های container را چک کنید
2. اطمینان حاصل کنید PostgreSQL در حال اجراست
3. Environment variables را دوباره بررسی کنید

### خطای Database Connection

- بررسی کنید که PostgreSQL سالم است: `docker exec n8n-postgres pg_isready`
- اطمینان حاصل کنید که credentials درست هستند

### مشکل SSL Certificate

- اطمینان حاصل کنید DNS رکورد به IP سرور اشاره می‌کند
- منتظر بمانید تا DNS propagate شود (معمولاً چند دقیقه)
- در Coolify لاگ‌های certificate generation را چک کنید

### Webhook ها کار نمی‌کنند

- اطمینان حاصل کنید `WEBHOOK_URL` درست تنظیم شده
- بررسی کنید که دامنه از بیرون قابل دسترسی است

## بروزرسانی n8n

برای بروزرسانی به نسخه جدید:

1. در Coolify به پروژه n8n بروید
2. اگر از Docker Compose استفاده می‌کنید، روی **"Redeploy"** کلیک کنید
3. اگر از Docker Image استفاده می‌کنید، Image را به نسخه جدید تغییر دهید

**توجه:** قبل از بروزرسانی حتماً backup بگیرید!

## منابع مفید

- [مستندات رسمی n8n](https://docs.n8n.io/)
- [مستندات Coolify](https://coolify.io/docs)
- [GitHub n8n](https://github.com/n8n-io/n8n)

## پشتیبانی

اگر با مشکلی مواجه شدید:

1. لاگ‌های Coolify را چک کنید
2. لاگ‌های container n8n را بررسی کنید: `docker logs n8n`
3. به [کامیونیتی n8n](https://community.n8n.io/) مراجعه کنید
