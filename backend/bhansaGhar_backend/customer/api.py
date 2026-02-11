from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from restaurants.models import Restaurant, MenuItem, Category
from .serializers import RestaurantContentSerializer, RestaurantPublicSerializer
import cloudinary.uploader


class AdminRestaurantPermission:
    """Check if user is the restaurant owner"""
    
    @staticmethod
    def has_permission(user, restaurant):
        return user.is_authenticated and restaurant.owner == user


@api_view(['GET', 'PUT'])
@permission_classes([IsAuthenticated])
def admin_restaurant_content(request, slug):
    """
    GET: Retrieve restaurant content for admin panel editing
    PUT: Update restaurant public content (about, hero_image, contact info)
    """
    restaurant = get_object_or_404(Restaurant, slug=slug)
    
    # Check if user is the owner
    if not AdminRestaurantPermission.has_permission(request.user, restaurant):
        return Response(
            {'error': 'You do not have permission to edit this restaurant'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    if request.method == 'GET':
        serializer = RestaurantContentSerializer(restaurant)
        return Response(serializer.data)
    
    elif request.method == 'PUT':
        serializer = RestaurantContentSerializer(restaurant, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def admin_upload_menu_image(request):
    """
    Upload a menu item image or hero image
    Expects: file in request.FILES['image']
    Returns: { 'url': cloudinary_url }
    """
    if 'image' not in request.FILES:
        return Response(
            {'error': 'No image file provided'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    file = request.FILES['image']
    
    try:
        # Upload to Cloudinary
        result = cloudinary.uploader.upload(file, folder='bhansa_ghar/menu_uploads/')
        return Response(
            {'url': result['secure_url']},
            status=status.HTTP_201_CREATED
        )
    except Exception as e:
        return Response(
            {'error': f'Upload failed: {str(e)}'},
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['GET'])
def public_restaurant_data(request, slug):
    """
    Public API to fetch restaurant data for public websites
    No authentication required
    """
    restaurant = get_object_or_404(Restaurant, slug=slug, is_active=True)
    serializer = RestaurantPublicSerializer(restaurant)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def admin_add_menu_item(request, slug):
    """
    Admin: Add a new menu item to a restaurant
    """
    restaurant = get_object_or_404(Restaurant, slug=slug)
    
    # Check if user is the owner
    if not AdminRestaurantPermission.has_permission(request.user, restaurant):
        return Response(
            {'error': 'You do not have permission to edit this restaurant'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        category_id = request.data.get('category_id')
        category = Category.objects.get(id=category_id, restaurant=restaurant)
        
        menu_item = MenuItem.objects.create(
            restaurant=restaurant,
            category=category,
            name=request.data.get('name'),
            description=request.data.get('description', ''),
            base_price=request.data.get('base_price'),
        )
        
        # Handle image if provided
        if 'image' in request.FILES:
            file = request.FILES['image']
            result = cloudinary.uploader.upload(
                file,
                folder=f'bhansa_ghar/menu/{restaurant.id}/'
            )
            menu_item.image = result['secure_url']
            menu_item.save()
        
        from .serializers import MenuItemSerializer
        serializer = MenuItemSerializer(menu_item)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    except Category.DoesNotExist:
        return Response(
            {'error': 'Category not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['GET'])
def admin_restaurant_list(request):
    """
    Admin: Get all restaurants owned by the authenticated user
    """
    if not request.user.is_authenticated:
        return Response(
            {'error': 'Authentication required'},
            status=status.HTTP_401_UNAUTHORIZED
        )
    
    restaurants = Restaurant.objects.filter(owner=request.user)
    serializer = RestaurantPublicSerializer(restaurants, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)
