from drf_spectacular.utils import extend_schema
from drf_spectacular.views import SpectacularAPIView

def create_role_filter_hook(role_prefix):
    def hook(endpoints):
        filtered = []
        for entry in endpoints:
            # Structure: (path, path_regex, method, callback)
            if len(entry) >= 3:
                path = entry[0]
            else:
                continue

            # Robust Path-based filtering logic
            is_match = False
            
            if role_prefix == 'Admin:':
                # Admin: Everything in core and most of restaurants
                if path.startswith('/api/core/'):
                    is_match = True
                elif path.startswith('/api/restaurants/') and not any(x in path for x in ['validate-table-qr', 'claim-invite', 'tables-status']):
                    is_match = True
                    
            elif role_prefix == 'Kitchen:':
                # Kitchen: Everything in orders/kitchen
                if path.startswith('/api/orders/kitchen/'):
                    is_match = True
                    
            elif role_prefix == 'Waiter:':
                # Waiter: Everything in orders/waiter, api/waiter/ and some restaurant status
                if path.startswith('/api/orders/waiter/') or path.startswith('/api/waiter/'):
                    is_match = True
                elif 'tables-status' in path or '/status/' in path:
                    is_match = True
                    
            elif role_prefix == 'Customer:':
                # Customer: Everything in orders/customer, QR validation, and dirty table report
                if path.startswith('/api/orders/customer/'):
                    is_match = True
                elif any(x in path for x in ['validate-table-qr', 'report-dirty']):
                    is_match = True
                elif 'claim-invite' in path: # Landing page for staff onboarding
                    is_match = True
            
            if is_match:
                filtered.append(entry)
            elif not role_prefix:
                filtered.append(entry)
        
        return filtered
    return hook

# Pre-defined hooks for each role
admin_hook = 'core.schema.admin_hook_func'
kitchen_hook = 'core.schema.kitchen_hook_func'
waiter_hook = 'core.schema.waiter_hook_func'
customer_hook = 'core.schema.customer_hook_func'

# Exported functions for spectacular to import by string
admin_hook_func = create_role_filter_hook('Admin:')
kitchen_hook_func = create_role_filter_hook('Kitchen:')
waiter_hook_func = create_role_filter_hook('Waiter:')
customer_hook_func = create_role_filter_hook('Customer:')

class AdminSchemaView(SpectacularAPIView):
    custom_settings = {'PREPROCESSING_HOOKS': [admin_hook]}

class KitchenSchemaView(SpectacularAPIView):
    custom_settings = {'PREPROCESSING_HOOKS': [kitchen_hook]}

class WaiterSchemaView(SpectacularAPIView):
    custom_settings = {'PREPROCESSING_HOOKS': [waiter_hook]}

class CustomerSchemaView(SpectacularAPIView):
    custom_settings = {'PREPROCESSING_HOOKS': [customer_hook]}
