"""
Custom storage backend for Cloudinary image uploads
"""
import logging
from cloudinary_storage.storage import MediaCloudinaryStorage
from django.core.files.base import File
import cloudinary
import cloudinary.uploader

logger = logging.getLogger(__name__)


class OptimizedCloudinaryStorage(MediaCloudinaryStorage):
    """
    Custom Cloudinary storage that ensures proper file uploads
    and verifies file existence after save
    """
    
    def save(self, name, content, max_length=None):
        """
        Override save to ensure proper Cloudinary upload
        """
        print(f"📤 [OptimizedCloudinaryStorage.save()] Saving file: {name}")
        print(f"📤 Content type: {type(content)}")
        print(f"📤 Content size: {content.size if hasattr(content, 'size') else 'Unknown'}")
        print(f"📤 Cloudinary config cloud_name: {cloudinary.config().cloud_name}")
        print(f"📤 Cloudinary config api_key: {cloudinary.config().api_key}")
        
        try:
            # Ensure content is at the beginning
            if hasattr(content, 'seek'):
                try:
                    content.seek(0)
                    print(f"✅ Content seeked to start")
                except:
                    print(f"⚠️ Could not seek content")
            
            # Call parent save which handles Cloudinary upload
            print(f"📤 Calling parent save() to upload to Cloudinary...")
            saved_name = super().save(name, content, max_length)
            
            print(f"✅ File saved result: {saved_name}")
            
            # Verify file exists in Cloudinary
            try:
                if self.exists(saved_name):
                    size = self.size(saved_name)
                    print(f"✅ File verified in Cloudinary: {saved_name} (Size: {size} bytes)")
                else:
                    print(f"⚠️ File NOT verified in Cloudinary after save: {saved_name}")
            except Exception as e:
                print(f"⚠️ Could not verify Cloudinary file: {e}")
            
            return saved_name
            
        except Exception as e:
            print(f"❌ Error saving to Cloudinary: {e}")
            print(f"❌ Exception type: {type(e).__name__}")
            logger.error(f"Cloudinary upload error for {name}: {e}", exc_info=True)
            raise
    
    def url(self, name):
        """
        Override url to ensure we get the full Cloudinary URL
        """
        print(f"📎 [OptimizedCloudinaryStorage.url()] Getting URL for: {name}")
        try:
            # Call parent url method
            url = super().url(name)
            print(f"📎 Parent URL result: {url}")
            
            # Ensure it's a full URL
            if url and not url.startswith('http'):
                # If it starts with /, it's a relative path, use Cloudinary's URL directly
                print(f"⚠️ URL is relative, attempting to get Cloudinary URL...")
                # Get the resource info from Cloudinary
                try:
                    result = cloudinary.api.resource(name)
                    if result and 'secure_url' in result:
                        url = result['secure_url']
                        print(f"✅ Got Cloudinary secure_url: {url}")
                except Exception as e:
                    print(f"⚠️ Could not get Cloudinary resource info: {e}")
            
            return url
        except Exception as e:
            print(f"❌ Error getting URL: {e}")
            logger.error(f"Error getting URL for {name}: {e}", exc_info=True)
            # Fallback: return a constructed URL
            constructed_url = f"https://res.cloudinary.com/{cloudinary.config().cloud_name}/image/upload/{name}"
            
            # Fix double media path issue
            if '/v1/media/' in constructed_url:
                fixed_url = constructed_url.replace('/v1/media/', '/v1/')
                print(f"🔧 Fixed Cloudinary URL: {fixed_url}")
                return fixed_url
                
            return constructed_url
    
    def delete(self, name):
        """
        Override delete with proper error handling
        """
        print(f"🗑️ [OptimizedCloudinaryStorage.delete()] Deleting file: {name}")
        try:
            super().delete(name)
            print(f"✅ File deleted from Cloudinary: {name}")
        except Exception as e:
            print(f"⚠️ Error deleting from Cloudinary: {e}")
            logger.warning(f"Error deleting {name} from Cloudinary: {e}")

