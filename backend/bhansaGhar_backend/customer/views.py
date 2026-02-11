from django.shortcuts import render, get_object_or_404, redirect
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.views import View
from django.contrib import messages
from django.utils import timezone
from django.utils.crypto import get_random_string
from django.db import models
from datetime import timedelta
import json
from restaurants.models import Restaurant, Category, MenuItem, Table
from orders.models import Order
from customer.models import LandingPage, FooterLink, SocialMediaLink, ContentPage, AppCard, Testimonial

def get_table_from_request(request, table_id=None):
    """Helper to get table from URL param or session, with security checks"""
    table = None
    
    # First try URL parameter (from QR scan)
    if table_id:
        try:
            table = Table.objects.get(id=table_id, is_active=True)
            # Set session on first access
            request.session['table_id'] = str(table.id)
            request.session['session_start'] = timezone.now().isoformat()
            # Update table status to occupied if available
            if table.status == 'available':
                table.status = 'occupied'
                table.save()
        except Table.DoesNotExist:
            return None
    
    # Fallback to session
    if not table:
        session_table_id = request.session.get('table_id')
        if session_table_id:
            try:
                table = Table.objects.get(id=session_table_id, is_active=True)
                # Check session timeout (1 hour)
                session_start = request.session.get('session_start')
                if session_start:
                    start_time = timezone.datetime.fromisoformat(session_start)
                    if timezone.now() - start_time > timedelta(hours=1):
                        # Session expired, clear it
                        request.session.flush()
                        return None
            except Table.DoesNotExist:
                request.session.flush()
                return None
    
    return table

def menu_view(request, table_id=None):
    """Main menu page for customers - QR access only"""
    table = get_table_from_request(request, table_id)
    
    if not table:
        return render(request, 'customer/scan_qr.html')
    
    restaurant = table.restaurant
    
    categories = restaurant.categories.all()
    menu_items = restaurant.menu_items.all()

    # Prepare menu items with safe image URLs
    menu_items_with_images = []
    for item in menu_items:
        item_data = {
            'id': item.id,
            'name': item.name,
            'description': item.description,
            'base_price': item.base_price,
            'category': item.category,
            'image_url': item.image.url if item.image else '',
        }
        menu_items_with_images.append(item_data)

    context = {
        'restaurant': restaurant,
        'categories': categories,
        'menu_items': menu_items_with_images,
        'table': table,
        'session_start': request.session.get('session_start'),
    }

    return render(request, 'customer/menu.html', context)

def orders_view(request, table_id=None):
    """Orders page for customers - session based"""
    table = get_table_from_request(request, table_id)
    
    if not table:
        return render(request, 'customer/scan_qr.html')
    
    # Filter by restaurant and table_number
    orders = Order.objects.filter(
        restaurant=table.restaurant,
        table_number=table.number
    ).order_by('-created_at')
    
    context = {
        'table': table,
        'orders': orders,
        'session_start': request.session.get('session_start'),
    }

    return render(request, 'customer/orders.html', context)

@method_decorator(csrf_exempt, name='dispatch')
class CartView(View):
    """API for cart operations - session secured"""

    def get(self, request, table_id=None):
        """Get cart items for a table"""
        table = get_table_from_request(request, table_id)
        if not table:
            return JsonResponse({'error': 'Invalid session. Please scan QR code.'}, status=403)
        
        # For now, return empty cart (in real app, use session-based cart)
        cart = {
            'items': [],
            'total': 0
        }
        return JsonResponse(cart)

    def post(self, request, table_id=None):
        """Add item to cart or create order"""
        table = get_table_from_request(request, table_id)
        if not table:
            return JsonResponse({'error': 'Invalid session. Please scan QR code.'}, status=403)
        
        try:
            data = json.loads(request.body)

            if data.get('action') == 'order':
                # Build items list and calculate total
                items_payload = []
                subtotal = 0
                
                requested_items = data.get('items', [])
                if not requested_items:
                     return JsonResponse({'error': 'No items in order'}, status=400)

                for item in requested_items:
                    try:
                        menu_item = MenuItem.objects.get(id=item['id'])
                        qty = int(item['quantity'])
                        if qty < 1: continue
                        
                        price = menu_item.base_price * (1 - menu_item.discount_percentage / 100)
                        subtotal += float(price) * qty
                        
                        items_payload.append({
                            'item_id': menu_item.id,
                            'qty': qty,
                            'name': menu_item.name, # Storing name for easier display if menu item deleted
                            'price': float(price),
                            'notes': item.get('notes', '')
                        })
                    except MenuItem.DoesNotExist:
                        continue
                
                if not request.session.session_key:
                    request.session.save()
                
                order = Order.objects.create(
                    restaurant=table.restaurant,
                    table_number=table.number,
                    session_id=request.session.session_key,
                    customer_notes=data.get('notes', ''),
                    status='pending',
                    items=items_payload,
                    subtotal=subtotal
                )

                # Update table status to preparing
                table.status = 'preparing'
                table.save()
                
                return JsonResponse({'order_id': str(order.id), 'status': 'created'})

            return JsonResponse({'error': 'Invalid action'}, status=400)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)

def leave_table(request):
    """Leave table - clear session and update table status"""
    table_id = request.session.get('table_id')
    if table_id:
        try:
            table = Table.objects.get(id=table_id)
            # Reset table status to available if it was occupied/ordering
            if table.status in ['occupied', 'ordering']:
                table.status = 'available'
                table.save()
        except Table.DoesNotExist:
            pass
    
    # Clear session
    request.session.flush()
    messages.success(request, 'You have successfully left the table.')
    return redirect('customer_home')


# ============ PUBLIC WEBSITE VIEWS ============

def restaurant_list(request):
    """Homepage - Show all active restaurants with dynamic landing page content"""
    from customer.models import LandingPage
    
    restaurants = Restaurant.objects.filter(is_active=True).order_by('name')
    
    # Get landing page content or create default
    landing_page = LandingPage.objects.filter(is_active=True).first()
    
    # Prepare restaurant data with images and item counts
    restaurant_data = []
    for restaurant in restaurants:
        menu_count = restaurant.menu_items.count()
        table_count = restaurant.tables.filter(is_active=True).count()
        
        restaurant_data.append({
            'id': restaurant.id,
            'name': restaurant.name,
            'slug': restaurant.slug,
            'description': restaurant.description,
            'about': restaurant.about,
            'hero_image': restaurant.hero_image.url if restaurant.hero_image else '',
            'address': restaurant.address,
            'phone': restaurant.phone,
            'menu_count': menu_count,
            'table_count': table_count,
        })
    
    context = {
        'restaurants': restaurant_data,
        'page_type': 'homepage',
        'landing_page': landing_page,  # Add landing page content
    }
    return render(request, 'customer/restaurant_list_dynamic.html', context)


def validate_table_session(request, slug=None, table_number=None):
    """Validate if user has a valid table session with optional slug/table_number checks"""
    table_token = request.session.get('table_token')
    table_id = request.session.get('table_id')
    
    if not table_token or not table_id:
        return None
    
    try:
        table = Table.objects.get(id=table_id, is_active=True)
        
        # Check if slug matches (if provided)
        if slug and table.restaurant.slug != slug:
            return None
        
        # Check if table number matches (if provided)
        if table_number and table.number != int(table_number):
            return None
        
        # Check if session is still valid (15 min TTL)
        session_created = request.session.get('table_session_created')
        if session_created:
            session_time = timezone.datetime.fromisoformat(session_created)
            if timezone.now() - session_time > timedelta(minutes=15):
                request.session.flush()
                return None
        
        return table
    except (Table.DoesNotExist, ValueError):
        return None


def public_restaurant(request, slug):
    """Public restaurant landing page - browse menu without ordering"""
    restaurant = get_object_or_404(Restaurant, slug=slug, is_active=True)
    
    categories = restaurant.categories.all()
    menu_items = restaurant.menu_items.all()
    
    # If no categories exist, create some sample data
    if not categories.exists():
        # Create sample categories
        sample_categories = [
            {'name': 'Tea & Beverages', 'description': 'Hot and cold beverages'},
            {'name': 'Snacks', 'description': 'Light snacks and appetizers'},
            {'name': 'Main Course', 'description': 'Main dishes'},
        ]
        for cat_data in sample_categories:
            Category.objects.get_or_create(
                restaurant=restaurant,
                name=cat_data['name'],
                defaults={'description': cat_data['description'], 'is_active': True}
            )
        categories = restaurant.categories.all()
    
    # If no menu items exist, create some sample data
    if not menu_items.exists() and categories.exists():
        sample_menu_items = [
            {'name': 'Masala Chai', 'description': 'Traditional spiced tea', 'price': 50, 'category': categories[0]},
            {'name': 'Black Tea', 'description': 'Classic black tea', 'price': 40, 'category': categories[0]},
            {'name': 'Green Tea', 'description': 'Healthy green tea', 'price': 45, 'category': categories[0]},
            {'name': 'Samosa', 'description': 'Crispy potato filled pastry', 'price': 30, 'category': categories[1]},
            {'name': 'Pakora', 'description': 'Vegetable fritters', 'price': 35, 'category': categories[1]},
            {'name': 'Chicken Momo', 'description': 'Steamed dumplings with chicken', 'price': 120, 'category': categories[2]},
            {'name': 'Veg Momo', 'description': 'Steamed vegetable dumplings', 'price': 100, 'category': categories[2]},
        ]
        for item_data in sample_menu_items:
            MenuItem.objects.get_or_create(
                restaurant=restaurant,
                name=item_data['name'],
                defaults={
                    'description': item_data['description'],
                    'base_price': item_data['price'],
                    'category': item_data['category'],
                    'is_active': True,
                    'is_available': True
                }
            )
        menu_items = restaurant.menu_items.all()
    
    # Prepare menu items with safe image URLs
    menu_items_with_images = []
    for item in menu_items:
        item_data = {
            'id': item.id,
            'name': item.name,
            'description': item.description,
            'base_price': float(item.base_price),
            'category': item.category,
            'image_url': item.image.url if item.image else '',
        }
        menu_items_with_images.append(item_data)
    
    # Get gallery images
    gallery = restaurant.gallery_images.filter(is_active=True).order_by('position')
    
    # Get testimonials
    testimonials = restaurant.testimonials.filter(is_active=True).order_by('order', '-created_at')
    
    # If no testimonials exist, create some sample data
    if not testimonials.exists():
        sample_testimonials = [
            {'author': 'Sarah Johnson', 'rating': 5, 'text': 'Amazing tea selection and the atmosphere is perfect for relaxation. The staff is very friendly!'},
            {'author': 'Rajesh Sharma', 'rating': 5, 'text': 'Best chai in Kathmandu! Authentic masala tea and delicious snacks.'},
            {'author': 'Priya Patel', 'rating': 4, 'text': 'Great place for a quick tea break. Clean, comfortable, excellent service.'},
        ]
        for i, test_data in enumerate(sample_testimonials):
            Testimonial.objects.get_or_create(
                restaurant=restaurant,
                author_name=test_data['author'],
                defaults={
                    'rating': test_data['rating'],
                    'text': test_data['text'],
                    'is_active': True,
                    'order': i
                }
            )
        testimonials = restaurant.testimonials.filter(is_active=True).order_by('order', '-created_at')
    
    # Get social media links (restaurant-specific or global)
    social_links = SocialMediaLink.objects.filter(
        models.Q(restaurant=restaurant) | models.Q(restaurant__isnull=True, landing_page__isnull=True)
    ).order_by('order')
    
    # If no restaurant-specific links, create some sample data
    if not social_links.filter(restaurant=restaurant).exists():
        sample_social_links = [
            {'platform': 'facebook', 'icon': '📘', 'url': 'https://facebook.com/bcachayawala'},
            {'platform': 'instagram', 'icon': '📷', 'url': 'https://instagram.com/bcachayawala'},
            {'platform': 'twitter', 'icon': '🐦', 'url': 'https://twitter.com/bcachayawala'},
        ]
        for i, social in enumerate(sample_social_links):
            SocialMediaLink.objects.get_or_create(
                restaurant=restaurant,
                platform=social['platform'],
                defaults={
                    'icon': social['icon'],
                    'url': social['url'],
                    'is_active': True,
                    'order': i
                }
            )
        social_links = SocialMediaLink.objects.filter(
            models.Q(restaurant=restaurant) | models.Q(restaurant__isnull=True, landing_page__isnull=True)
        ).order_by('order')
    
    context = {
        'restaurant': restaurant,
        'categories': categories,
        'menu_items': menu_items_with_images,
        'gallery': gallery,
        'testimonials': testimonials,
        'social_links': social_links,
        'table_valid': False,
        'page_type': 'public',
    }
    return render(request, 'customer/public_menu.html', context)


def scan_qr(request, slug, table_number):
    """QR scan endpoint - validates table and creates session"""
    restaurant = get_object_or_404(Restaurant, slug=slug, is_active=True)
    
    # Validate table exists and belongs to this restaurant
    table = get_object_or_404(
        Table, 
        restaurant=restaurant, 
        number=table_number, 
        is_active=True
    )
    
    # Create table token (15 min TTL)
    table_token = get_random_string(32)
    request.session['table_token'] = table_token
    request.session['table_id'] = str(table.id)
    request.session['table_session_created'] = timezone.now().isoformat()
    request.session.set_expiry(900)  # 15 minutes
    
    # Update table status to occupied
    if table.status == 'available':
        table.status = 'occupied'
        table.save()
    
    return redirect('customer:gated_menu', slug=slug, table_number=table_number)


def gated_menu(request, slug, table_number):
    """Gated menu page - full ordering with cart enabled"""
    # Validate table session
    table = validate_table_session(request, slug=slug, table_number=table_number)
    
    if not table:
        return redirect('customer:public_restaurant', slug=slug)
    
    restaurant = table.restaurant
    categories = restaurant.categories.all()
    menu_items = restaurant.menu_items.all()
    
    # Prepare menu items with safe image URLs
    menu_items_with_images = []
    for item in menu_items:
        item_data = {
            'id': item.id,
            'name': item.name,
            'description': item.description,
            'base_price': float(item.base_price),
            'category': item.category,
            'image_url': item.image.url if item.image else '',
        }
        menu_items_with_images.append(item_data)
    
    context = {
        'restaurant': restaurant,
        'categories': categories,
        'menu_items': menu_items_with_images,
        'table': table,
        'table_valid': True,
        'page_type': 'gated',
    }
    return render(request, 'customer/full_menu.html', context)


@method_decorator(csrf_exempt, name='dispatch')
class PublicCartView(View):
    """API for gated menu cart operations - session secured"""
    
    def post(self, request, slug, table_number):
        """Add item to cart or create order (requires valid table session)"""
        # Validate table session
        table = validate_table_session(request, slug=slug, table_number=table_number)
        
        if not table:
            return JsonResponse(
                {'error': 'Invalid or expired session. Please scan QR code again.'}, 
                status=403
            )
        
        try:
            data = json.loads(request.body)
            
            if data.get('action') == 'order':
                # Build items list and calculate total
                items_payload = []
                subtotal = 0
                
                requested_items = data.get('items', [])
                if not requested_items:
                    return JsonResponse({'error': 'No items in order'}, status=400)
                
                for item in requested_items:
                    try:
                        menu_item = MenuItem.objects.get(id=item['id'])
                        qty = int(item['quantity'])
                        if qty < 1:
                            continue
                        
                        # Calculate price (base price for now, extend with modifiers later)
                        price = float(menu_item.base_price)
                        subtotal += price * qty
                        
                        items_payload.append({
                            'item_id': str(menu_item.id),
                            'qty': qty,
                            'name': menu_item.name,
                            'price': price,
                            'notes': item.get('notes', '')
                        })
                    except MenuItem.DoesNotExist:
                        continue
                
                if not items_payload:
                    return JsonResponse({'error': 'No valid items in order'}, status=400)
                
                if not request.session.session_key:
                    request.session.save()
                
                order = Order.objects.create(
                    restaurant=table.restaurant,
                    table_number=table.number,
                    session_id=request.session.session_key,
                    customer_notes=data.get('notes', ''),
                    status='pending',
                    items=items_payload,
                    subtotal=subtotal
                )
                
                return JsonResponse({
                    'order_id': str(order.id),
                    'status': 'created',
                    'total': float(subtotal)
                })
            
            return JsonResponse({'error': 'Invalid action'}, status=400)
        
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)


def landing_page_view(request):
    """
    Render the dynamic landing page with content from LandingPage model
    and active restaurants from Restaurant model.
    """
    try:
        # Get the active landing page
        landing_page = LandingPage.objects.filter(is_active=True).first()
        
        if not landing_page:
            # Create a default landing page if none exists
            landing_page = LandingPage.objects.create(
                brand_name="BhansaGhar",
                logo="🍽️",
                hero_title="Discover Amazing Food",
                hero_subtitle="Order from your favorite restaurants with just a few clicks",
                info_banner_icon="🎉",
                info_banner_text="🎉 Welcome to our food ordering platform - Fast, Easy, and Delicious!",
                feature_1_icon="⚡",
                feature_1_title="Fast Delivery",
                feature_1_description="Get your food delivered quickly to your doorstep",
                feature_2_icon="🎯",
                feature_2_title="Quality Assured",
                feature_2_description="Only the best restaurants and freshest ingredients",
                feature_3_icon="💎",
                feature_3_title="Easy to Use",
                feature_3_description="Simple and intuitive interface for seamless ordering",
                about_title="About Our Platform",
                about_description="We're revolutionizing the restaurant industry by connecting food lovers with their favorite local restaurants through innovative technology.",
                about_description_2="Whether you're a restaurant owner looking to streamline operations or a customer seeking the perfect meal, we provide the tools and support to make it happen seamlessly.",
                highlight_1="Trusted by Top Restaurants",
                highlight_2="Real-time Order Tracking",
                highlight_3="Secure Payments",
                highlight_4="24/7 Customer Support",
                cta_title="Ready to Order?",
                cta_description="Browse through our collection of amazing restaurants and enjoy your favorite meals.",
                cta_button_text="Start Ordering Now",
                footer_tagline="Your one-stop platform for discovering and ordering from the best restaurants in your area.",
                footer_text="© 2024 BhansaGhar. All rights reserved.",
                is_active=True,
            )
        
        # Get active restaurants
        restaurants = Restaurant.objects.filter(is_active=True).select_related('type')
        
        # Calculate restaurant count
        restaurants_count = restaurants.count()
        
        # Get footer links organized by section
        footer_links = FooterLink.objects.filter(is_active=True).order_by('section', 'order')
        footer_sections = {}
        for link in footer_links:
            if link.section not in footer_sections:
                footer_sections[link.section] = []
            footer_sections[link.section].append(link)
        
        # Get active social media links for this landing page
        social_links = SocialMediaLink.objects.filter(
            landing_page=landing_page,
            is_active=True
        ).select_related('platform').order_by('order')
        
        # Get active app cards
        app_cards = AppCard.objects.filter(is_active=True).order_by('order')
        
        context = {
            'landing_page': landing_page,
            'restaurants': restaurants,
            'restaurants_count': restaurants_count,
            'footer_sections': footer_sections,
            'social_links': social_links,
            'app_cards': app_cards,
        }
        
        return render(request, 'customer/landing_page.html', context)
    
    except Exception as e:
        print(f"Error rendering landing page: {str(e)}")
        footer_links = FooterLink.objects.filter(is_active=True).order_by('section', 'order')
        footer_sections = {}
        for link in footer_links:
            if link.section not in footer_sections:
                footer_sections[link.section] = []
            footer_sections[link.section].append(link)
        
        social_links = SocialMediaLink.objects.filter(
            is_active=True
        ).select_related('platform').order_by('order')
        app_cards = AppCard.objects.filter(is_active=True).order_by('order')
        
        return render(request, 'customer/landing_page.html', {
            'landing_page': None,
            'restaurants': Restaurant.objects.filter(is_active=True),
            'restaurants_count': Restaurant.objects.filter(is_active=True).count(),
            'footer_sections': footer_sections,
            'social_links': social_links,
            'app_cards': app_cards,
            'error': str(e)
        })


def content_page_api(request, slug):
    """
    API endpoint to fetch content pages for modal display
    """
    try:
        content_page = get_object_or_404(ContentPage, slug=slug, is_active=True)
        return JsonResponse({
            'title': content_page.title,
            'content': content_page.content,
        })
    except Exception as e:
        return JsonResponse({
            'error': str(e),
        }, status=404)


# ============================================================================
# API Views for Super Admin - Landing Page Management
# ============================================================================

from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from .serializers import LandingPageSerializer, AppCardSerializer, LandingPagePublicSerializer, AppCardPublicSerializer


class IsSuperAdmin(IsAdminUser):
    """Permission check for super admin (staff + is_superuser)"""
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_staff and request.user.is_superuser)


@api_view(['GET', 'PUT', 'PATCH'])
@permission_classes([IsAuthenticated, IsSuperAdmin])
@authentication_classes([])
def landing_page_admin_view(request):
    """
    Super Admin endpoint to get/update landing page content
    GET: Retrieve current landing page data
    PUT/PATCH: Update landing page data with image uploads
    """
    try:
        landing_page = LandingPage.objects.filter(is_active=True).first()
        
        if not landing_page:
            return Response(
                {'error': 'No active landing page found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        if request.method == 'GET':
            serializer = LandingPageSerializer(landing_page)
            return Response(serializer.data, status=status.HTTP_200_OK)
        
        elif request.method in ['PUT', 'PATCH']:
            serializer = LandingPageSerializer(
                landing_page,
                data=request.data,
                partial=(request.method == 'PATCH')
            )
            
            if serializer.is_valid():
                serializer.save()
                return Response(
                    {
                        'success': True,
                        'message': 'Landing page updated successfully',
                        'data': serializer.data
                    },
                    status=status.HTTP_200_OK
                )
            else:
                return Response(
                    {'errors': serializer.errors},
                    status=status.HTTP_400_BAD_REQUEST
                )
    
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([])  # Public endpoint
def landing_page_public_view(request):
    """
    Public endpoint to retrieve landing page data for frontend display
    """
    try:
        landing_page = LandingPage.objects.filter(is_active=True).first()
        
        if not landing_page:
            return Response(
                {'error': 'No active landing page found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = LandingPagePublicSerializer(landing_page)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated, IsSuperAdmin])
@authentication_classes([])
def app_cards_admin_view(request):
    """
    Super Admin endpoint to list and create app cards
    GET: List all app cards
    POST: Create a new app card with optional SVG code or image
    """
    try:
        if request.method == 'GET':
            app_cards = AppCard.objects.all().order_by('order')
            serializer = AppCardSerializer(app_cards, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        
        elif request.method == 'POST':
            serializer = AppCardSerializer(data=request.data)
            
            if serializer.is_valid():
                serializer.save()
                return Response(
                    {
                        'success': True,
                        'message': 'App card created successfully',
                        'data': serializer.data
                    },
                    status=status.HTTP_201_CREATED
                )
            else:
                return Response(
                    {'errors': serializer.errors},
                    status=status.HTTP_400_BAD_REQUEST
                )
    
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([IsAuthenticated, IsSuperAdmin])
@authentication_classes([])
def app_cards_detail_view(request, pk):
    """
    Super Admin endpoint to retrieve, update, or delete a specific app card
    """
    try:
        app_card = AppCard.objects.get(id=pk)
    except AppCard.DoesNotExist:
        return Response(
            {'error': 'App card not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    if request.method == 'GET':
        serializer = AppCardSerializer(app_card)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    elif request.method in ['PUT', 'PATCH']:
        serializer = AppCardSerializer(
            app_card,
            data=request.data,
            partial=(request.method == 'PATCH')
        )
        
        if serializer.is_valid():
            serializer.save()
            return Response(
                {
                    'success': True,
                    'message': 'App card updated successfully',
                    'data': serializer.data
                },
                status=status.HTTP_200_OK
            )
        else:
            return Response(
                {'errors': serializer.errors},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    elif request.method == 'DELETE':
        app_card.delete()
        return Response(
            {'success': True, 'message': 'App card deleted successfully'},
            status=status.HTTP_204_NO_CONTENT
        )


@api_view(['GET'])
@permission_classes([])  # Public endpoint
def app_cards_public_view(request):
    """
    Public endpoint to retrieve active app cards for frontend display
    """
    try:
        app_cards = AppCard.objects.filter(is_active=True).order_by('order')
        serializer = AppCardPublicSerializer(app_cards, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
