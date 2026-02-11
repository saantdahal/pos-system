"""
Core module - Main application logic organized into submodules

Folder structure:
├── admin/              - Django admin configurations (12 files)
├── activities/         - Activity tracking and logging
├── services/          - Reusable services (caching, email, storage, health checks, postman)
├── migrations/         - Django migrations
├── management/         - Django management commands
├── templates/          - HTML templates
├── models.py           - Core data models
├── serializers.py      - DRF serializers
├── views.py            - API views and endpoints
├── urls.py             - URL routing
├── signals.py          - Django signals
├── schema.py           - Schema definitions
└── apps.py             - App configuration

This structure provides clear separation of concerns:
- Admin functionality is isolated in the admin/ package
- Activity/logging features are in activities/
- Reusable services (cache, email, storage, health checks) are in services/
- Core business logic remains in models.py, views.py, serializers.py

NOTE: Admin imports are done in urls.py to avoid circular imports during app initialization
NOTE: Services are lazily imported to avoid circular dependencies during app initialization
"""

# Import activity utilities (safe - no circular dependencies)
from .activities import (  # noqa: F401
    log_activity,
)

__all__ = [
    'log_activity',
]
