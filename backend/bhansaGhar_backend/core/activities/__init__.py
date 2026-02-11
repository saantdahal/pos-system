"""
Activities module - Activity tracking, logging, and related utilities

Organized structure:
- activity_models.py: Activity log models
- activity_serializers.py: Serializers for activity data
- activity_utils.py: Utility functions for activity processing
- activity_views.py: Views and endpoints for activity data
"""

from .activity_utils import (
    log_activity,
)

__all__ = [
    'log_activity',
]
