"""
Inline admin classes for nested model editing
"""
from django.contrib import admin

from restaurants.models import Table, Category, MenuItem
from ..models import User


class TableInline(admin.TabularInline):
    """Inline tables for restaurant"""
    model = Table
    extra = 0
    fields = ['number', 'capacity', 'is_available']
    max_num = 50


class StaffInline(admin.TabularInline):
    """Inline staff members for restaurant"""
    model = User
    extra = 0
    fields = ['username', 'email', 'role', 'is_active']
    fk_name = 'restaurant'
    max_num = 50


class MenuItemInline(admin.TabularInline):
    """Inline menu items for category"""
    model = MenuItem
    extra = 0
    fields = ['name', 'price', 'vegetarian', 'is_available']
    max_num = 100


class CategoryInline(admin.TabularInline):
    """Inline categories for restaurant"""
    model = Category
    extra = 0
    fields = ['name', 'description']
    max_num = 20
