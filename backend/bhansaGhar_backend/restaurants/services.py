import qrcode
from io import BytesIO
from django.conf import settings
from restaurants.models import Table
import cloudinary
import cloudinary.uploader

class QRGenerator:
    @staticmethod
    def generate_table_qr(restaurant, table_number):
        print(f"🎨 Generating QR code for restaurant {restaurant.id}, table {table_number}")
        # Get the table object to use its UUID
        table = Table.objects.get(restaurant=restaurant, number=table_number)
        print(f"📋 Found table: {table.id}")
        
        # Secure QR URL using table UUID (unique and hard to guess)
        qr_url = f"{settings.SITE_URL}/customer/menu/{table.id}/"
        print(f"🔗 QR URL: {qr_url}")

        # Generate QR code
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(qr_url)
        qr.make(fit=True)

        # Create image
        img = qr.make_image(fill_color="black", back_color="white")
        img_buffer = BytesIO()
        img.save(img_buffer, format='PNG')
        
        # Check buffer size BEFORE seeking
        buffer_size = len(img_buffer.getvalue())
        print(f"🖼️ QR image generated, buffer size: {buffer_size} bytes")
        
        if buffer_size == 0:
            print(f"❌ ERROR: QR image buffer is empty!")
            raise Exception("Failed to generate QR code image")
        
        # Reset buffer position for upload
        img_buffer.seek(0)

        # Upload directly to Cloudinary using the upload API
        file_name = f"qr_table_{restaurant.id}_{table_number}.png"
        folder_path = f"qr_codes"
        print(f"☁️ Uploading to Cloudinary folder: {folder_path}/{file_name}")

        try:
            # Upload directly to Cloudinary
            upload_result = cloudinary.uploader.upload(
                img_buffer,
                public_id=file_name,
                folder=folder_path,
                resource_type="image",
                overwrite=True,
            )
            
            print(f"✅ Uploaded to Cloudinary successfully")
            print(f"✅ Public ID: {upload_result.get('public_id')}")
            print(f"✅ Version: {upload_result.get('version')}")
            
            # Get the secure HTTPS URL from Cloudinary response
            secure_url = upload_result.get('secure_url')
            print(f"✅ Secure URL: {secure_url}")
            
            if not secure_url:
                raise Exception("No secure_url returned from Cloudinary upload")
            
            # Store the Cloudinary path in qr_code_image field
            cloudinary_path = f"{upload_result.get('public_id')}.{upload_result.get('format')}"
            table.qr_code_image = cloudinary_path
            table.qr_url = secure_url
            
            print(f"💾 Set table.qr_code_image = {table.qr_code_image}")
            print(f"💾 Set table.qr_url = {table.qr_url}")
            table.save()
            print(f"💾 Table saved successfully")

            return table.qr_url
            
        except Exception as e:
            print(f"❌ Error uploading QR code to Cloudinary: {e}")
            import traceback
            traceback.print_exc()
            raise
