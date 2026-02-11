from django import template

register = template.Library()


@register.filter
def get_item(dictionary, key):
    """Get item from dictionary using key"""
    if isinstance(dictionary, dict):
        return dictionary.get(key, [])
    return []


@register.filter
def startswith(value, arg):
    """Check if string starts with given prefix"""
    if isinstance(value, str):
        return value.startswith(arg)
    return False

