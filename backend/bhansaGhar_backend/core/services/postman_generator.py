"""
Postman Collection Generator for BhansaGhar API
Generates a complete Postman collection with all endpoints, request types, and examples
"""

import json
import os
from typing import Any, Dict, List


class PostmanCollectionGenerator:
    """Generate Postman collection from API endpoints"""
    
    BASE_URL = "http://127.0.0.1:8000"
    COLLECTION_PATH = "postman_collection.json"
    
    def __init__(self) -> None:
        self.collection: Dict[str, Any] = {
            "info": {
                "name": "BhansaGhar Backend API",
                "description": "Complete API collection for BhansaGhar Restaurant Management System",
                "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
            },
            "item": [],
            "variable": [
                {
                    "key": "base_url",
                    "value": self.BASE_URL,
                    "type": "string"
                },
                {
                    "key": "access_token",
                    "value": "",
                    "type": "string"
                },
                {
                    "key": "refresh_token",
                    "value": "",
                    "type": "string"
                }
            ]
        }
    
    def add_request(
        self,
        method: str,
        url: str,
        name: str,
        description: str = "",
        body: Dict[str, Any] | None = None,
        auth_required: bool = False,
        response_example: Dict[str, Any] | None = None,
    ) -> None:
        """Add a request to the collection"""
        
        request: Dict[str, Any] = {
            "name": name,
            "description": description,
            "request": {
                "method": method,
                "header": [
                    {
                        "key": "Content-Type",
                        "value": "application/json"
                    }
                ],
                "url": {
                    "raw": f"{{{{base_url}}}}{url}",
                    "protocol": "http",
                    "host": ["127", "0", "0", "1"],
                    "port": "8000",
                    "path": url.lstrip("/").split("/")
                }
            }
        }
        
        # Add authentication header if required
        if auth_required:
            request["request"]["header"].append({
                "key": "Authorization",
                "value": "Bearer {{access_token}}"
            })
        
        # Add body if provided
        if body:
            request["request"]["body"] = {
                "mode": "raw",
                "raw": json.dumps(body, indent=2),
                "options": {
                    "raw": {
                        "language": "json"
                    }
                }
            }
        
        # Add response example if provided
        if response_example:
            request["response"] = [
                {
                    "name": f"{name} - Success Response",
                    "originalRequest": request["request"],
                    "status": "OK",
                    "code": 200,
                    "header": [
                        {
                            "key": "Content-Type",
                            "value": "application/json"
                        }
                    ],
                    "body": json.dumps(response_example, indent=2)
                }
            ]
        
        self.collection["item"].append(request)
    
    def generate(self) -> None:
        """Generate all API endpoints"""
        
        # 1. Google Authentication Endpoint
        self.add_request(
            method="POST",
            url="/api/core/auth/google/",
            name="Google OAuth - Authenticate User",
            description="Step 1: Authenticate user with Google OAuth token",
            body={
                "id_token": "YOUR_GOOGLE_ID_TOKEN_HERE"
            },
            response_example={
                "message": "Google authentication successful. Please verify your email.",
                "email": "user@example.com",
                "verification_sent": True,
                "user_status": {
                    "is_google_verified": True,
                    "is_email_verified": False,
                    "profile_completed": False
                }
            }
        )
        
        # 2. Send Verification Code
        self.add_request(
            method="POST",
            url="/api/core/auth/send-code/",
            name="Send Email Verification Code",
            description="Request to send verification code to email",
            body={
                "email": "user@example.com"
            },
            response_example={
                "message": "Verification code sent to your email",
                "temp_code": "123456"
            }
        )
        
        # 3. Verify Email Code
        self.add_request(
            method="POST",
            url="/api/core/auth/verify-code/",
            name="Verify Email Code",
            description="Step 2: Verify email with verification code",
            body={
                "email": "user@example.com",
                "code": "123456"
            },
            response_example={
                "message": "Email verified successfully!",
                "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
                "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
                "user": {
                    "id": 1,
                    "username": "user",
                    "email": "user@example.com",
                    "google_id": "123456789",
                    "is_google_verified": True,
                    "is_email_verified": True,
                    "profile_completed": False,
                    "role": None,
                    "restaurant": None
                },
                "user_status": {
                    "is_google_verified": True,
                    "is_email_verified": True,
                    "profile_completed": False,
                    "restaurant_created": False
                },
                "next_step": "complete_profile"
            }
        )
        
        # 3.5. Resend Verification Code
        self.add_request(
            method="POST",
            url="/api/core/auth/resend-code/",
            name="Resend Email Verification Code",
            description="Resend verification code if not received (2 minute cooldown)",
            body={
                "email": "user@example.com"
            },
            response_example={
                "message": "Verification code sent successfully"
            }
        )
        
        # 4. Complete Profile
        self.add_request(
            method="POST",
            url="/api/core/profile/complete/",
            name="Complete User Profile & Create Restaurant",
            description="Step 3: Complete profile, create restaurant, and set admin role",
            body={
                "username": "restaurant_owner",
                "phone": "9841234567",
                "address": "Thamel, Kathmandu",
                "latitude": 27.7172,
                "longitude": 85.3240,
                "restaurant_name": "My Restaurant"
            },
            auth_required=True,
            response_example={
                "success": True,
                "message": "Profile completed and restaurant created successfully!",
                "user": {
                    "id": 1,
                    "username": "restaurant_owner",
                    "email": "user@example.com",
                    "google_id": "123456789",
                    "is_google_verified": True,
                    "is_email_verified": True,
                    "profile_completed": True,
                    "role": "admin",
                    "restaurant": 1
                },
                "restaurant": {
                    "id": "550e8400-e29b-41d4-a716-446655440000",
                    "name": "My Restaurant",
                    "type": "restaurant"
                },
                "ready_for_dashboard": True
            }
        )
        
        # 5. Admin Status Check
        self.add_request(
            method="GET",
            url="/api/core/status/",
            name="Check Admin Registration Status",
            description="Check current admin registration progress",
            auth_required=True,
            response_example={
                "is_admin": True,
                "is_google_verified": True,
                "is_email_verified": True,
                "profile_completed": True,
                "restaurant_created": True,
                "ready_for_dashboard": True
            }
        )
        
        # 6. Test User Endpoint
        self.add_request(
            method="GET",
            url="/api/core/test/",
            name="Get Current User Info",
            description="Retrieve current authenticated user information (requires full verification)",
            auth_required=True,
            response_example={
                "id": 1,
                "username": "restaurant_owner",
                "email": "user@example.com",
                "role": "admin",
                "phone": "9841234567",
                "profile_completed": True,
                "restaurant": "My Restaurant"
            }
        )
        
        # 7. Token Refresh
        self.add_request(
            method="POST",
            url="/api/core/token/refresh/",
            name="Refresh Access Token",
            description="Refresh JWT access token using refresh token",
            body={
                "refresh": "{{refresh_token}}"
            },
            response_example={
                "access": "eyJ0eXAiOiJKV1QiLCJhbGc..."
            }
        )
    
    def save(self) -> str:
        """Save collection to file and return path"""
        # Ensure the collection is generated
        self.generate()
        
        # Get the project root or use current directory
        current_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(os.path.dirname(current_dir))
        collection_path = os.path.join(project_root, self.COLLECTION_PATH)
        
        # Write the collection to file
        with open(collection_path, 'w') as f:
            json.dump(self.collection, f, indent=2)
        
        return collection_path
    
    def get_collection(self) -> Dict[str, Any]:
        """Get the generated collection dictionary"""
        self.generate()
        return self.collection


def create_postman_collection() -> str:
    """Create and save Postman collection"""
    generator = PostmanCollectionGenerator()
    path = generator.save()
    return path
