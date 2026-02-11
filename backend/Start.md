# Getting Started - BhansaGhar Backend

## 🔧 Quick Start

The backend now uses a **single `.env` file** for all configurations. No more environment switching!

### Setup

```bash
cd backend/bhansaGhar_backend

# Install dependencies
pip install -r requirements.txt

# Create and configure .env file
cp .env.example .env
nano .env  # Edit with your local database credentials

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Collect static files
python manage.py collectstatic

# Start development server
python manage.py runserver 0.0.0.0:8000
```

### Access Points

- **API:** http://localhost:8000/api/
- **Swagger UI:** http://localhost:8000/api/docs/
- **ReDoc:** http://localhost:8000/api/redoc/
- **Admin Panel:** http://localhost:8000/admin/

---

## 📋 Environment Configuration (.env File)

### Core Settings

```env
# Django Settings
DEBUG=True
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1

# URLs
SITE_URL=http://localhost:8000
FRONTEND_URL=http://localhost:3000
```

### Database (PostgreSQL)

```env
DB_ENGINE=django.db.backends.postgresql
DB_NAME=bhansaghar
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=localhost
DB_PORT=5432
VALIDATE_DB_ON_STARTUP=True
```

### Cache (Redis)

```env
REDIS_URL=redis://127.0.0.1:6379/1
```

### Email

```env
EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=noreply@bhansaghar.com
```

### Cloud Storage (Cloudinary)

```env
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

### Google OAuth

```env
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
```

### Security Settings (adjust based on environment)

```env
# Development
SECURE_SSL_REDIRECT=False
SESSION_COOKIE_SECURE=False
CSRF_COOKIE_SECURE=False
SECURE_HSTS_SECONDS=0

# Production
SECURE_SSL_REDIRECT=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
SECURE_HSTS_SECONDS=31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS=True
SECURE_HSTS_PRELOAD=True
```

---

## 🚀 Development

### Run Development Server

```bash
python manage.py runserver
```

### Features in Development

- DEBUG=True (detailed error pages)
- HTTP allowed (no SSL required)
- Console email backend (prints to terminal)
- Relaxed CORS (localhost:3000, localhost:8081)
- Verbose logging

### Common Commands

```bash
# Create migrations
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Load sample data
python manage.py loaddata initial_data

# Access Django shell
python manage.py shell

# Run tests
python manage.py test

# Collect static files
python manage.py collectstatic --noinput

# Check deployment readiness
python manage.py check --deploy
```

---

## 🟡 Staging/Production Deployment

### Using Gunicorn

```bash
gunicorn -w 4 \
  -b 0.0.0.0:8000 \
  --timeout 60 \
  --access-logfile - \
  --error-logfile - \
  bhansaGhar_backend.wsgi
```

### Using Systemd Service

Create `/etc/systemd/system/bhansaghar.service`:

```ini
[Unit]
Description=BhansaGhar Django Application
After=network.target postgresql.service redis-server.service

[Service]
Type=notify
User=www-data
WorkingDirectory=/var/www/bhansaghar/backend/bhansaGhar_backend
EnvironmentFile=/var/www/bhansaghar/.env
ExecStart=/var/www/bhansaghar/venv/bin/gunicorn \
  --workers 8 \
  --bind 127.0.0.1:8000 \
  --timeout 120 \
  --access-logfile /var/log/bhansaghar/access.log \
  --error-logfile /var/log/bhansaghar/error.log \
  bhansaGhar_backend.wsgi

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable bhansaghar
sudo systemctl start bhansaghar
sudo systemctl status bhansaghar
```

### Using Docker

```bash
docker-compose up -d
```

---

## 🔗 Nginx Configuration

Create `/etc/nginx/sites-available/bhansaghar`:

```nginx
upstream django {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name api.bhansaghar.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.bhansaghar.com;

    ssl_certificate /etc/letsencrypt/live/api.bhansaghar.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.bhansaghar.com/privkey.pem;

    client_max_body_size 20M;

    location / {
        proxy_pass http://django;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /var/www/bhansaghar/backend/staticfiles/;
    }

    location /media/ {
        alias /var/www/bhansaghar/backend/media/;
    }
}
```

Enable:

```bash
sudo ln -s /etc/nginx/sites-available/bhansaghar /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

## 📊 Configuration by Environment

Adjust `.env` based on your environment:

| Setting | Development | Production |
|---------|-------------|------------|
| DEBUG | True | False |
| SECURE_SSL_REDIRECT | False | True |
| SESSION_COOKIE_SECURE | False | True |
| CSRF_COOKIE_SECURE | False | True |
| EMAIL_BACKEND | console | smtp |
| ALLOWED_HOSTS | * | your-domain.com |
| SECURE_HSTS_SECONDS | 0 | 31536000 |

---

## ✅ Pre-Deployment Checklist

- [ ] All variables set in `.env`
- [ ] Database created and migrated
- [ ] `python manage.py check --deploy` passes
- [ ] Static files collected
- [ ] SSL certificate installed
- [ ] Redis running
- [ ] Superuser created
- [ ] Logs directory exists with proper permissions
- [ ] Media directory is writable

---

## 🆘 Troubleshooting

### PostgreSQL Connection Failed

```bash
# Check credentials in .env
cat .env | grep DB_

# Test connection
psql -U postgres -h localhost -d bhansaghar
```

### Redis Connection Issues

```bash
# Check Redis is running
redis-cli ping

# Check Redis URL in .env
echo $REDIS_URL
```

### Port Already in Use

```bash
# Find process using port 8000
lsof -i :8000

# Kill process
kill -9 <PID>
```

### Debug Django Settings

```bash
python manage.py shell
>>> from django.conf import settings
>>> print(settings.DEBUG)
>>> print(settings.ALLOWED_HOSTS)
```

---

## 📝 Notes

- The configuration now uses a **single `.env` file**
- All settings are environment-variable driven
- No more `env-switch.sh` or environment-specific settings files
- Simply adjust `.env` values for your deployment environment
- Production and development use the same Django settings module
