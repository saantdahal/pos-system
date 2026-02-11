"""
Django settings for BhansaGhar Backend
Single unified configuration using .env file
"""
import os
import cloudinary
from decouple import AutoConfig
from pathlib import Path
import logging
from datetime import timedelta

# Load environment variables from .env file
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

try:
    import cloudinary
except ImportError:
    cloudinary = None

BASE_DIR = Path(__file__).resolve().parent.parent

config = AutoConfig()

# ============================================================================
# CORE SETTINGS
# ============================================================================
SECRET_KEY = config('SECRET_KEY', default='your-secret-key-here')

DEBUG = config('DEBUG', default=False, cast=bool)

ALLOWED_HOSTS = str(config('ALLOWED_HOSTS', default='*')).split(',')

SITE_URL = config('SITE_URL', default='bansa.nnine.training')
FRONTEND_URL = config('FRONTEND_URL', default='bhansa.nnine.training')

# ============================================================================
# APPLICATIONS
# ============================================================================
INSTALLED_APPS = [
    'admin_interface',
    'colorfield',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.sites',  # Required for allauth
    
    # 3rd party
    'rest_framework',
    'rest_framework.authtoken',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'channels',  # WebSocket
    'cloudinary_storage',
    'cloudinary',
    'django_crontab',
    'drf_spectacular',
    
    # Google OAuth + Allauth
    'allauth',
    'allauth.account',
    'allauth.socialaccount',
    'allauth.socialaccount.providers.google',
    'dj_rest_auth',
    'dj_rest_auth.registration',
    
    # Local apps
    'core',
    'restaurants',
    'orders',
    'websocket',
    'customer',
    'notifications',
    'analytics',
    'invoices',
]

# ============================================================================
# TEMPLATES
# ============================================================================
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [
            BASE_DIR / 'templates',
            BASE_DIR / 'core' / 'templates',
            BASE_DIR / 'customer' / 'templates',
        ],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
                'django.template.context_processors.request',
            ],
        },
    },
]

# ============================================================================
# MIDDLEWARE
# ============================================================================
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'allauth.account.middleware.AccountMiddleware',
]

# ============================================================================
# SECURITY SETTINGS
# ============================================================================
SECURE_SSL_REDIRECT = config('SECURE_SSL_REDIRECT', default=False, cast=bool)
SESSION_COOKIE_SECURE = config('SESSION_COOKIE_SECURE', default=False, cast=bool)
CSRF_COOKIE_SECURE = config('CSRF_COOKIE_SECURE', default=False, cast=bool)
SECURE_HSTS_SECONDS = config('SECURE_HSTS_SECONDS', default=0, cast=int)
SECURE_HSTS_INCLUDE_SUBDOMAINS = config('SECURE_HSTS_INCLUDE_SUBDOMAINS', default=False, cast=bool)
SECURE_HSTS_PRELOAD = config('SECURE_HSTS_PRELOAD', default=False, cast=bool)
CSRF_COOKIE_HTTPONLY = True
SESSION_COOKIE_HTTPONLY = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'

SITE_ID = 1

# ============================================================================
# STATIC & MEDIA FILES
# ============================================================================
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_DIRS = [
    BASE_DIR / 'core' / 'static',
    BASE_DIR / 'customer' / 'static',
]

STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.StaticFilesStorage'

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

ROOT_URLCONF = 'bhansaGhar_backend.urls'

# ============================================================================
# DATABASE
# ============================================================================
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        # 'NAME': config('DB_NAME'),
        # 'USER': config('DB_USER'),
        # 'PASSWORD': config('DB_PASSWORD'),
        # 'HOST': config('DB_HOST', 'localhost'),
        # 'PORT': config('DB_PORT', 5432),
        # 'CONN_MAX_AGE': 600,
        'NAME': 'BhansaGhar',                    # Hardcoded
        'USER': 'postgres',                      # Hardcoded
        'PASSWORD': 'sakkar.com',                # Hardcoded
        'HOST': 'bhansaghar-postgres',           # Hardcoded - Docker container name
        'PORT': 5432,                            # Hardcoded - Container port
        'CONN_MAX_AGE': 600,
        'OPTIONS': {
            'connect_timeout': 10,
        }
    }
}

# Database validation on startup
logger = logging.getLogger(__name__)

def validate_database_connection():
    """Validate PostgreSQL connection and log detailed error information"""
    try:
        import psycopg2
        
        conn = psycopg2.connect(
            # dbname=config('DB_NAME'),
            # user=config('DB_USER'),
            # password=config('DB_PASSWORD'),
            # host=config('DB_HOST', 'localhost'),
            # port=config('DB_PORT', 5432),
            # connect_timeout=10,
            dbname='BhansaGhar',           # Hardcoded
            user='postgres',               # Hardcoded
            password='sakkar.com',         # Hardcoded
            host='bhansaghar-postgres',    # Hardcoded - Docker container name
            port=5432,                     # Hardcoded - Container port
            connect_timeout=10,
        )
        conn.close()
        logger.info("✓ PostgreSQL connection successful")
        if DEBUG:
            print("✓ PostgreSQL connection successful 😘")
        return True
        
    except Exception as e:
        error_msg = f"Database connection failed: {str(e)}"
        logger.error(error_msg)
        if DEBUG:
            print(f"✗ {error_msg}")
        raise Exception(error_msg)

# Validate connection on startup
if config('VALIDATE_DB_ON_STARTUP', default=True, cast=bool):
    try:
        validate_database_connection()
    except Exception as e:
        logger.critical(f"Database connection validation failed: {str(e)}")
        if DEBUG:
            print(f"\n⚠️  CRITICAL: Database connection failed during startup!")
            print(f"Please ensure PostgreSQL is running and credentials in .env are correct.\n")
        raise

# ============================================================================
# REST FRAMEWORK
# ============================================================================
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle'
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',
        'user': '1000/day'
    },
}

# ============================================================================
# API DOCUMENTATION (DRF SPECTACULAR)
# ============================================================================
SPECTACULAR_SETTINGS = {
    'TITLE': 'BhansaGhar API',
    'DESCRIPTION': 'API documentation for BhansaGhar Restaurant Management System',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'COMPONENT_SPLIT_PATCH': True,
    'COMPONENT_SPLIT_REQUEST': True,
    'ENUM_NAME_OVERRIDES': {
        'TableStatusEnum': 'restaurants.models.BaseTableStatus',
        'StaffInviteRoleEnum': 'restaurants.models.BaseStaffInviteRole',
        'StaffInviteStatusEnum': 'restaurants.models.BaseStaffInviteStatus',
        'OrderStatusEnum': 'orders.models.BaseOrderStatus',
        'BargainStatusEnum': 'orders.models.BaseBargainStatus',
        'UserRoleEnum': 'core.models.BaseUserRole',
    },
}

# ============================================================================
# JWT SETTINGS
# ============================================================================
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=12),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
}

# ============================================================================
# AUTHENTICATION & AUTHORIZATION
# ============================================================================
AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',
    'allauth.account.auth_backends.AuthenticationBackend',
]

AUTH_USER_MODEL = 'core.User'

# Allauth settings
ACCOUNT_LOGIN_METHODS = {'email'}
ACCOUNT_SIGNUP_FIELDS = ['email*', 'password1*', 'password2*']
ACCOUNT_EMAIL_VERIFICATION = 'none'
SOCIALACCOUNT_AUTO_SIGNUP = True
SOCIALACCOUNT_STORE_TOKENS = True

# ============================================================================
# CACHING (REDIS)
# ============================================================================
if DEBUG:
    # Use in-memory cache for development (avoids Redis connection issues on macOS)
    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
            "LOCATION": "unique-snowflake",
        }
    }
else:
    # Use Redis for production
    CACHES = {
        "default": {
            "BACKEND": "django_redis.cache.RedisCache",
            "LOCATION": config('REDIS_URL', default='redis://127.0.0.1:6379/1'),
            "OPTIONS": {
                "CLIENT_CLASS": "django_redis.client.DefaultClient",
                "CONNECTION_POOL_KWARGS": {
                    "max_connections": 50,
                    "socket_keepalive": True,
                    "socket_keepalive_options": {1: 1, 2: 3, 3: 3},
                },
                "COMPRESSOR": "django_redis.compressors.zlib.ZlibCompressor",
            }
        }
    }

SESSION_ENGINE = "django.contrib.sessions.backends.cache"
SESSION_CACHE_ALIAS = "default"
SESSION_COOKIE_AGE = 86400
SESSION_EXPIRE_AT_BROWSER_CLOSE = False

# ============================================================================
# WEBSOCKETS (CHANNELS)
# ============================================================================
ASGI_APPLICATION = 'bhansaGhar_backend.asgi.application'
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            "hosts": [config('REDIS_URL', default='redis://127.0.0.1:6379/0')],
        },
    },
}

# ============================================================================
# CORS
# ============================================================================
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://192.168.1.100:8080",
    "https://yourcafe.com",
]

# ============================================================================
# GOOGLE OAUTH
# ============================================================================
GOOGLE_CLIENT_ID = config('GOOGLE_CLIENT_ID', default='')
GOOGLE_CLIENT_SECRET = config('GOOGLE_CLIENT_SECRET', default='')

# ============================================================================
# EMAIL CONFIGURATION
# ============================================================================
if DEBUG:
    EMAIL_BACKEND = 'core.email_backend.DevelopmentEmailBackend'
else:
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

EMAIL_HOST = config('EMAIL_HOST', default='smtp.gmail.com')
EMAIL_PORT = config('EMAIL_PORT', default=587, cast=int)
EMAIL_USE_TLS = config('EMAIL_USE_TLS', default=True, cast=bool)
EMAIL_HOST_USER = config('EMAIL_HOST_USER', default='')
EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD', default='')
DEFAULT_FROM_EMAIL = config('DEFAULT_FROM_EMAIL', default='noreply@bhansaghar.com')

# ============================================================================
# DEFAULT AUTO FIELD
# ============================================================================
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ============================================================================
# CLOUDINARY CONFIGURATION
# ============================================================================
if cloudinary:
    cloudinary.config(
        cloud_name=config('CLOUDINARY_CLOUD_NAME', default=''),
        api_key=config('CLOUDINARY_API_KEY', default=''),
        api_secret=config('CLOUDINARY_API_SECRET', default='')
    )

    CLOUDINARY_STORAGE = {
        'CLOUD_NAME': config('CLOUDINARY_CLOUD_NAME', default=''),
        'API_KEY': config('CLOUDINARY_API_KEY', default=''),
        'API_SECRET': config('CLOUDINARY_API_SECRET', default=''),
    }

    DEFAULT_FILE_STORAGE = 'core.storage.OptimizedCloudinaryStorage'
else:
    logger.warning("Cloudinary not installed. Image uploads will use local storage.")

# ============================================================================
# LOGGING
# ============================================================================
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {asctime} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'simple',
        },
        'file': {
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': BASE_DIR / 'logs' / 'django.log',
            'maxBytes': 1024 * 1024 * 10,  # 10MB
            'backupCount': 10,
            'formatter': 'verbose',
        },
        'null': {
            'class': 'logging.NullHandler',
        },
    },
    'root': {
        'handlers': ['console'] if DEBUG else ['console', 'file'],
        'level': 'INFO' if DEBUG else 'INFO',  # Set to INFO even in DEBUG mode to suppress verbose logs
    },
    'loggers': {
        'django': {
            'handlers': ['console'] if DEBUG else ['console', 'file'],
            'level': 'INFO' if DEBUG else 'INFO',  # Change to INFO even in DEBUG
            'propagate': False,
        },
        'watchfiles': {
            'level': 'CRITICAL',
            'propagate': False,
            'handlers': ['null'],
        },
        'urllib3': {
            'level': 'WARNING',
            'propagate': False,
            'handlers': ['null'],
        },
        'asyncio': {
            'level': 'WARNING',
            'propagate': False,
            'handlers': ['null'],
        },
    },
}

# ============================================================================
# CRON JOBS
# ============================================================================
CRONJOBS = [
    ('*/15 * * * *', 'restaurants.management.commands.cleanup_expired_invites.Command'),
    ('0 0 * * *', 'analytics.tasks.update_daily_analytics'),
    ('0 * * * *', 'analytics.tasks.update_hourly_analytics'),
    ('0 2 * * *', 'analytics.tasks.update_top_items'),
    ('0 3 * * 0', 'analytics.tasks.cleanup_old_analytics'),
]
