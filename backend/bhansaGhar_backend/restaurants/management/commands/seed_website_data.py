"""
Management command to seed restaurant website data
Includes hero images, gallery images, and professional descriptions
Images are organized in Cloudinary: restaurant/{restaurant_slug}/website/{type}/
"""

from django.core.management.base import BaseCommand
from django.core.files.base import ContentFile
from restaurants.models import Restaurant, RestaurantGallery
from PIL import Image, ImageDraw, ImageFont
from io import BytesIO
import random


class Command(BaseCommand):
    help = 'Seed restaurant website data with hero images and gallery'

    def create_placeholder_image(self, width, height, text, colors):
        """Create a beautiful placeholder image with text"""
        img = Image.new('RGB', (width, height), color=colors['bg'])
        draw = ImageDraw.Draw(img)
        
        # Add gradient-like effect with colored rectangles
        for i in range(height):
            color_val = int(colors['r1'] + (colors['r2'] - colors['r1']) * i / height)
            draw.line([(0, i), (width, i)], fill=(
                int(colors['r1'][0] + (colors['r2'][0] - colors['r1'][0]) * i / height),
                int(colors['r1'][1] + (colors['r2'][1] - colors['r1'][1]) * i / height),
                int(colors['r1'][2] + (colors['r2'][2] - colors['r1'][2]) * i / height),
            ))
        
        # Add text
        text_size = width // 10
        try:
            draw.text((width//2, height//2), text, fill=(255, 255, 255), 
                     anchor="mm", font=None)
        except:
            pass
        
        return img

    def generate_hero_image(self, restaurant_name):
        """Generate a hero image for the restaurant"""
        width, height = 1200, 600
        
        # Different color schemes for different restaurants
        schemes = [
            {
                'name': 'Purple Sunset',
                'r1': (102, 126, 234),  # #667eea
                'r2': (118, 75, 162),   # #764ba2
                'bg': (102, 126, 234)
            },
            {
                'name': 'Orange Warmth',
                'r1': (255, 140, 0),
                'r2': (255, 69, 0),
                'bg': (255, 140, 0)
            },
            {
                'name': 'Green Fresh',
                'r1': (34, 177, 76),
                'r2': (0, 128, 96),
                'bg': (34, 177, 76)
            },
        ]
        
        scheme = random.choice(schemes)
        img = Image.new('RGB', (width, height), color=scheme['bg'])
        draw = ImageDraw.Draw(img)
        
        # Draw gradient background
        for i in range(height):
            r = int(scheme['r1'][0] + (scheme['r2'][0] - scheme['r1'][0]) * i / height)
            g = int(scheme['r1'][1] + (scheme['r2'][1] - scheme['r1'][1]) * i / height)
            b = int(scheme['r1'][2] + (scheme['r2'][2] - scheme['r1'][2]) * i / height)
            draw.line([(0, i), (width, i)], fill=(r, g, b))
        
        # Add semi-transparent overlay
        overlay = Image.new('RGBA', (width, height), (0, 0, 0, 100))
        img = img.convert('RGBA')
        img = Image.alpha_composite(img, overlay)
        
        # Add text with emoji
        text = f"🍽️ {restaurant_name}"
        try:
            draw = ImageDraw.Draw(img)
            # Draw text with white color
            draw.text((width//2, height//2), text, fill=(255, 255, 255, 255), anchor="mm")
        except:
            pass
        
        img = img.convert('RGB')
        
        # Convert to bytes
        img_io = BytesIO()
        img.save(img_io, format='JPEG', quality=85)
        img_io.seek(0)
        return img_io

    def generate_gallery_image(self, item_name, category_name):
        """Generate a gallery image for menu items"""
        width, height = 800, 600
        
        # Color palette for different categories
        category_colors = {
            'Momos': ((255, 140, 0), (255, 69, 0)),
            'Beverages': ((0, 150, 200), (0, 100, 150)),
            'Tea': ((139, 69, 19), (101, 50, 15)),
            'Coffee': ((139, 69, 19), (101, 50, 15)),
            'Snacks': ((184, 134, 11), (153, 102, 0)),
            'Hot Beverages': ((255, 99, 71), (220, 20, 60)),
            'Quick Bites': ((244, 164, 96), (210, 105, 30)),
            'Cold Drinks': ((0, 191, 255), (30, 144, 255)),
        }
        
        colors = category_colors.get(category_name, ((100, 100, 100), (50, 50, 50)))
        
        img = Image.new('RGB', (width, height), color=colors[0])
        draw = ImageDraw.Draw(img)
        
        # Draw gradient background
        for i in range(height):
            r = int(colors[0][0] + (colors[1][0] - colors[0][0]) * i / height)
            g = int(colors[0][1] + (colors[1][1] - colors[0][1]) * i / height)
            b = int(colors[0][2] + (colors[1][2] - colors[0][2]) * i / height)
            draw.line([(0, i), (width, i)], fill=(r, g, b))
        
        # Add decorative shapes
        for _ in range(10):
            x = random.randint(0, width)
            y = random.randint(0, height)
            size = random.randint(20, 80)
            draw.ellipse([(x-size, y-size), (x+size, y+size)], 
                        fill=(255, 255, 255, 30) if random.random() > 0.7 else None,
                        outline=(255, 255, 255, 50))
        
        # Add text
        text = f"🍽️ {item_name}"
        try:
            draw.text((width//2, height//2), text, fill=(255, 255, 255), anchor="mm")
        except:
            pass
        
        # Convert to bytes
        img_io = BytesIO()
        img.save(img_io, format='JPEG', quality=85)
        img_io.seek(0)
        return img_io

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS('🌱 Seeding restaurant website data...\n'))
        
        # Website content data
        restaurant_data = {
            'Bhol Momo House': {
                'description': 'Authentic Nepali momos and traditional dumplings',
                'about': '''Welcome to Bhol Momo House, where tradition meets taste! 

We've been serving authentic Nepali momos for over 15 years, using family recipes passed down through generations. Our skilled chefs prepare each batch fresh throughout the day using the finest ingredients sourced locally.

Our commitment to quality and customer satisfaction has made us a beloved destination for momo lovers across the city. Whether you prefer steamed or fried, meat or vegetable, we have the perfect momo for you.

Come experience the authentic taste of Nepal! 🍽️''',
                'gallery_items': [
                    {'name': 'Chicken Momo Platter', 'desc': 'Fresh steamed chicken momos'},
                    {'name': 'Vegetable Momo', 'desc': 'Seasonal fresh vegetables'},
                    {'name': 'Buff Momo Special', 'desc': 'Premium buff filling'},
                    {'name': 'Restaurant Interior', 'desc': 'Cozy dining ambiance'},
                    {'name': 'Chef Preparing Momos', 'desc': 'Traditional preparation'},
                    {'name': 'Happy Customers', 'desc': 'Satisfied diners'},
                ]
            },
            'BCA Chaya Wala': {
                'description': 'Premium tea and authentic Nepali snacks',
                'about': '''Experience the finest tea selection at BCA Chaya Wala!

Nestled in the heart of Patan, our tea house serves premium teas sourced from the best gardens across Nepal and India. From traditional Nepali masala chiya to aromatic Indian teas, we have something for every tea lover.

Paired with our homemade snacks and pastries, every visit is a delightful experience. Our warm ambiance and friendly staff make it the perfect place to unwind or catch up with friends.

Visit us for a perfect cup of chai! ☕''',
                'gallery_items': [
                    {'name': 'Masala Chiya Special', 'desc': 'Traditional spiced tea'},
                    {'name': 'Premium Tea Selection', 'desc': 'Various tea varieties'},
                    {'name': 'Fresh Pastries', 'desc': 'Homemade baked goods'},
                    {'name': 'Cozy Tea Room', 'desc': 'Warm and inviting space'},
                    {'name': 'Tea Service', 'desc': 'Traditional tea brewing'},
                    {'name': 'Evening Ambiance', 'desc': 'Perfect sunset setting'},
                ]
            },
            'Chaiwala Express': {
                'description': 'Quick chai and fast food for your busy day',
                'about': '''Chaiwala Express - Your go-to spot for quick bites and refreshing beverages!

Open early morning to late evening, we serve fresh coffee, tea, and quick snacks to fuel your day. Our fast service ensures you never have to wait, perfect for busy professionals and students.

From quick breakfast options to energy-boosting beverages, we've got everything you need to keep going. Our affordable prices and quality standards make us the favorite choice for thousands of daily visitors.

Stop by for quick refreshment! 🚀''',
                'gallery_items': [
                    {'name': 'Fresh Coffee', 'desc': 'Brewing aromatic coffee'},
                    {'name': 'Quick Breakfast', 'desc': 'Fast and tasty options'},
                    {'name': 'Egg Fried Rice', 'desc': 'Our signature quick dish'},
                    {'name': 'Modern Counter', 'desc': 'Fast service counter'},
                    {'name': 'Busy Service Time', 'desc': 'Popular during peak hours'},
                    {'name': 'Customer Queue', 'desc': 'Loved by many!'},
                ]
            }
        }
        
        restaurants = Restaurant.objects.filter(is_active=True)
        
        for restaurant in restaurants:
            self.stdout.write(f'\n📍 Processing: {restaurant.name}')
            
            # Get restaurant-specific data or use default
            rest_data = restaurant_data.get(restaurant.name, {
                'description': restaurant.description or 'Welcome to our restaurant!',
                'about': restaurant.about or 'Experience quality dining with us!',
                'gallery_items': []
            })
            
            # Update restaurant description and about
            if not restaurant.about or restaurant.about == '':
                restaurant.about = rest_data.get('about', '')
                restaurant.save()
                self.stdout.write(f'   ✓ Updated about section')
            
            # Generate and upload hero image
            if not restaurant.hero_image or restaurant.hero_image == '':
                self.stdout.write(f'   📸 Generating hero image...')
                hero_img = self.generate_hero_image(restaurant.name)
                
                filename = f'restaurant/{restaurant.slug}/website/hero/hero.jpg'
                restaurant.hero_image.save(filename, hero_img, save=True)
                self.stdout.write(f'   ✓ Hero image uploaded to: {filename}')
            
            # Add gallery items
            existing_gallery_count = restaurant.gallery_images.filter(is_active=True).count()
            
            if existing_gallery_count < 6:  # Only add if less than 6
                self.stdout.write(f'   🖼️ Adding gallery images...')
                
                gallery_items = rest_data.get('gallery_items', [])
                position = existing_gallery_count + 1
                
                for item in gallery_items[:6 - existing_gallery_count]:
                    # Generate gallery image
                    category_name = restaurant.categories.first().name if restaurant.categories.exists() else 'General'
                    gallery_img = self.generate_gallery_image(item['name'], category_name)
                    
                    # Create gallery entry
                    filename = f'restaurant/{restaurant.slug}/website/gallery/{item["name"].lower().replace(" ", "_")}.jpg'
                    
                    # Save file to gallery
                    gallery = RestaurantGallery(
                        restaurant=restaurant,
                        title=item['name'],
                        description=item['desc'],
                        position=position,
                        is_active=True
                    )
                    gallery.image.save(filename, gallery_img, save=True)
                    
                    self.stdout.write(f'      ✓ {item["name"]} - Folder: {filename}')
                    position += 1
            else:
                self.stdout.write(f'   ℹ️  Gallery already has {existing_gallery_count} items')
        
        # Print folder structure
        self.stdout.write(self.style.SUCCESS('\n\n📁 Cloudinary Folder Structure:'))
        self.stdout.write('''
restaurant/
├── bhol-momo-house/
│   └── website/
│       ├── hero/
│       │   └── hero.jpg
│       └── gallery/
│           ├── chicken_momo_platter.jpg
│           ├── vegetable_momo.jpg
│           ├── buff_momo_special.jpg
│           ├── restaurant_interior.jpg
│           ├── chef_preparing_momos.jpg
│           └── happy_customers.jpg
│
├── bca-chaya-wala/
│   └── website/
│       ├── hero/
│       │   └── hero.jpg
│       └── gallery/
│           ├── masala_chiya_special.jpg
│           ├── premium_tea_selection.jpg
│           ├── fresh_pastries.jpg
│           ├── cozy_tea_room.jpg
│           ├── tea_service.jpg
│           └── evening_ambiance.jpg
│
└── chaiwala-express/
    └── website/
        ├── hero/
        │   └── hero.jpg
        └── gallery/
            ├── fresh_coffee.jpg
            ├── quick_breakfast.jpg
            ├── egg_fried_rice.jpg
            ├── modern_counter.jpg
            ├── busy_service_time.jpg
            └── customer_queue.jpg
        ''')
        
        # Print optimization tips
        self.stdout.write(self.style.SUCCESS('\n📊 Optimization Tips:'))
        self.stdout.write('''
1. HERO IMAGES:
   - Aspect ratio: 2:1 (1200x600px recommended)
   - File size: < 300KB for faster loading
   - Quality: Compressed JPEG (85% quality)
   - Best practice: Professional photography or high-quality graphics

2. GALLERY IMAGES:
   - Aspect ratio: 4:3 (800x600px generated)
   - Display size: Thumbnail 160x120px (auto-fitted by CSS)
   - Organization: By restaurant slug and type
   - Format: JPEG with 85% quality for balance

3. IMAGE OPTIMIZATION:
   - Cloudinary auto-optimizes on delivery
   - Different sizes served based on device (responsive)
   - Lazy loading enabled in frontend
   - CDN caching for faster delivery

4. FOLDER STRUCTURE BENEFITS:
   - Easy to manage by restaurant owner
   - Clear separation of concerns (hero vs gallery)
   - Scalable for future additions
   - Better organization for Cloudinary dashboard
        ''')
        
        # Print data summary
        self.stdout.write(self.style.SUCCESS('\n✅ Data Summary:'))
        
        total_restaurants = Restaurant.objects.filter(is_active=True).count()
        total_gallery = RestaurantGallery.objects.filter(is_active=True).count()
        
        self.stdout.write(f'''
🏢 Restaurants with website data: {total_restaurants}
🖼️ Gallery images created: {total_gallery}
📍 Total locations: {total_restaurants}

Restaurant Details:
''')
        
        for restaurant in Restaurant.objects.filter(is_active=True):
            gallery_count = restaurant.gallery_images.filter(is_active=True).count()
            has_hero = '✓' if restaurant.hero_image else '✗'
            has_about = '✓' if restaurant.about else '✗'
            
            self.stdout.write(f'''
   📍 {restaurant.name}
      Hero Image: {has_hero}
      About Section: {has_about}
      Gallery Images: {gallery_count}/6
      Location: {restaurant.address}
      Phone: {restaurant.phone}
            ''')
        
        self.stdout.write(self.style.SUCCESS('\n🌐 Access Your Restaurant Website:'))
        self.stdout.write(f'''
Homepage: http://localhost:8000/
Restaurant List: http://localhost:8000/restaurants/

View Individual Restaurants:
''')
        
        for restaurant in Restaurant.objects.filter(is_active=True):
            self.stdout.write(f'   🍽️ {restaurant.name}: http://localhost:8000/restaurant/{restaurant.slug}/')
        
        self.stdout.write(self.style.SUCCESS('\n✅ Website data seeding complete!\n'))
