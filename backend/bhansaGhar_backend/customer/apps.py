from django.apps import AppConfig


class CustomerConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'customer'
    
    def ready(self):
        import customer.admin  # noqa
        import customer.signals  # noqa - Register signals for automatic image deletion
