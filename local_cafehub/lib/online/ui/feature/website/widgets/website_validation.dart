class WebsiteValidation {
  // Validate hex color format
  static String? validateHexColor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Color is required';
    }

    final hexRegex = RegExp(r'^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    if (!hexRegex.hasMatch(value)) {
      return 'Please enter a valid hex color (e.g., #FF6B6B)';
    }

    return null;
  }

  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    try {
      Uri.parse(value);
      if (!value.startsWith('http://') && !value.startsWith('https://')) {
        return 'URL must start with http:// or https://';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  // Validate phone number (basic)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    // Remove common phone formatting characters
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]+'), '');

    if (cleanNumber.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Validate website title
  static String? validateWebsiteTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Website title is required';
    }

    if (value.length < 3) {
      return 'Website title must be at least 3 characters';
    }

    if (value.length > 200) {
      return 'Website title must not exceed 200 characters';
    }

    return null;
  }

  // Validate content text
  static String? validateContent(
    String? value, {
    int? minLength,
    int? maxLength,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    if (minLength != null && value.length < minLength) {
      return 'Content must be at least $minLength characters';
    }

    if (maxLength != null && value.length > maxLength) {
      return 'Content must not exceed $maxLength characters';
    }

    return null;
  }

  // Validate image file
  static String? validateImageFile(String? filePath) {
    if (filePath == null || filePath.isEmpty) {
      return null; // Optional field
    }

    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final ext = filePath.split('.').last.toLowerCase();

    if (!validExtensions.contains(ext)) {
      return 'Please select a valid image file (jpg, png, gif, webp)';
    }

    return null;
  }

  // Validate image size (in MB)
  static String? validateImageSize(int fileSizeInBytes, {int maxSizeInMB = 5}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;

    if (fileSizeInBytes > maxSizeInBytes) {
      return 'Image size must not exceed ${maxSizeInMB}MB';
    }

    return null;
  }
}
