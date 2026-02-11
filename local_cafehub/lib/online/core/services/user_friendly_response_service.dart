import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Service to convert API errors and responses into user-friendly messages
class UserFriendlyResponseService {
  /// Convert any error/exception to a user-friendly message
  static String getErrorMessage(dynamic error, {String? context}) {
    debugPrint('📞 UserFriendlyResponseService: Processing error - $error');

    // Handle DioException (network/HTTP errors)
    if (error is DioException) {
      return _handleDioError(error, context: context);
    }

    // Handle Exception with message
    if (error is Exception) {
      return _handleGenericException(error, context: context);
    }

    // Handle string errors
    if (error is String) {
      return _handleStringError(error, context: context);
    }

    // Fallback for unknown error types
    return '⚠️ Something went wrong\n\n'
        'An unexpected error occurred.\n\n'
        'Please try again or contact support.';
  }

  /// Handle Dio-specific errors (network, HTTP status codes)
  static String _handleDioError(DioException error, {String? context}) {
    debugPrint('🔍 Handling DioException: ${error.type} - ${error.message}');

    // Check response error message from backend
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final backendMessage =
          responseData['error'] ??
          responseData['message'] ??
          responseData['detail'];

      if (backendMessage is String) {
        return _parseBackendError(backendMessage, context: context);
      }
    }

    // Handle by error type
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return '⏱️ Request Timeout\n\n'
            'The request took too long to complete.\n\n'
            'Please check your connection and try again.';

      case DioExceptionType.badResponse:
        return _handleHttpStatusCode(
          error.response?.statusCode ?? 0,
          context: context,
        );

      case DioExceptionType.connectionError:
        return '📡 Connection Error\n\n'
            'Unable to connect to the server.\n\n'
            'Please check your internet connection.';

      case DioExceptionType.unknown:
        if (error.error?.toString().contains('SocketException') ?? false) {
          return '📡 Network Error\n\n'
              'Unable to reach the server.\n\n'
              'Please check your internet connection.';
        }
        return '⚠️ Something went wrong\n\n'
            'An unexpected error occurred.\n\n'
            'Please try again.';

      default:
        return '⚠️ Request Failed\n\n'
            'The request could not be completed.\n\n'
            'Please try again.';
    }
  }

  /// Handle HTTP status codes
  static String _handleHttpStatusCode(int statusCode, {String? context}) {
    debugPrint('🔍 Handling HTTP $statusCode error');

    switch (statusCode) {
      case 400:
        return '⚠️ Invalid Request\n\n'
            'Please check your input and try again.';

      case 401:
        return '🔑 Session Expired\n\n'
            'Please log in again to continue.';

      case 403:
        return '🔒 Access Denied\n\n'
            'You do not have permission to perform this action.';

      case 404:
        return '🔍 Not Found\n\n'
            'The requested item was not found.\n\n'
            'It may have been deleted or moved.';

      case 409:
        return '⚡ Conflict\n\n'
            'This action conflicts with existing data.\n\n'
            'Please refresh and try again.';

      case 429:
        return '⏸️ Too Many Requests\n\n'
            'You\'re making requests too quickly.\n\n'
            'Please wait a moment and try again.';

      case 500:
      case 502:
      case 503:
      case 504:
        return '🔧 Server Error\n\n'
            'The server is experiencing issues.\n\n'
            'Please try again in a few moments.';

      default:
        return '⚠️ Request Failed\n\n'
            'Error code: $statusCode\n\n'
            'Please try again.';
    }
  }

  /// Parse backend error messages for specific conditions
  static String _parseBackendError(String message, {String? context}) {
    debugPrint('🔍 Parsing backend error: $message');

    final lowerMessage = message.toLowerCase();

    // Restaurant-related errors
    if (lowerMessage.contains('does not have a restaurant') ||
        lowerMessage.contains('no restaurant')) {
      return '🏪 No Restaurant Found\n\n'
          'Please create a restaurant first.\n\n'
          'Go to Restaurant Setup to get started.';
    }

    if (lowerMessage.contains('restaurant') &&
        (lowerMessage.contains('not found') ||
            lowerMessage.contains('does not exist'))) {
      return '🏪 Restaurant Not Found\n\n'
          'The restaurant could not be found.\n\n'
          'Please check and try again.';
    }

    // Menu-related errors
    if (lowerMessage.contains('menu') && lowerMessage.contains('not found')) {
      return '📋 Menu Not Found\n\n'
          'The menu could not be found.\n\n'
          'Please refresh and try again.';
    }

    // Category errors
    if (lowerMessage.contains('category')) {
      if (lowerMessage.contains('already exists')) {
        return '⚠️ Category Already Exists\n\n'
            'A category with this name already exists.\n\n'
            'Please use a different name.';
      }
      if (lowerMessage.contains('not found')) {
        return '🏷️ Category Not Found\n\n'
            'The category could not be found.\n\n'
            'Please refresh and try again.';
      }
    }

    // Email-related errors
    if (lowerMessage.contains('email')) {
      if (lowerMessage.contains('already')) {
        return '📧 Email Already Registered\n\n'
            'This email is already in use.\n\n'
            'Please use a different email.';
      }
      if (lowerMessage.contains('invalid')) {
        return '📧 Invalid Email\n\n'
            'Please enter a valid email address.';
      }
    }

    // Validation errors
    if (lowerMessage.contains('required') || lowerMessage.contains('must')) {
      return '✏️ Missing Required Field\n\n'
          'Please fill in all required fields.';
    }

    // Duplicate/conflict errors
    if (lowerMessage.contains('already exists')) {
      return '⚡ Item Already Exists\n\n'
          'This item already exists.\n\n'
          'Please try with a different value.';
    }

    // Generic backend error
    return '⚠️ Request Failed\n\n'
        '$message\n\n'
        'Please try again.';
  }

  /// Handle generic exceptions
  static String _handleGenericException(Exception error, {String? context}) {
    debugPrint('🔍 Handling generic exception: ${error.toString()}');

    final message = error.toString().toLowerCase();

    if (message.contains('socket') || message.contains('connection')) {
      return '📡 Connection Error\n\n'
          'Unable to connect to the server.\n\n'
          'Please check your internet connection.';
    }

    if (message.contains('timeout')) {
      return '⏱️ Request Timeout\n\n'
          'The request took too long.\n\n'
          'Please try again.';
    }

    return '⚠️ Something went wrong\n\n'
        'An unexpected error occurred.\n\n'
        'Please try again.';
  }

  /// Handle string errors
  static String _handleStringError(String error, {String? context}) {
    debugPrint('🔍 Handling string error: $error');

    if (error.toLowerCase().contains('restaurant')) {
      return '🏪 Restaurant Error\n\n'
          'There was an issue with your restaurant.\n\n'
          'Please try again.';
    }

    return '⚠️ Error\n\n'
        '$error\n\n'
        'Please try again.';
  }

  /// Get success message for common operations
  static String getSuccessMessage(String operation) {
    switch (operation.toLowerCase()) {
      case 'create':
        return 'Created successfully! ✨';
      case 'update':
        return 'Updated successfully! ✨';
      case 'delete':
        return 'Deleted successfully! ✨';
      case 'save':
        return 'Saved successfully! ✨';
      case 'upload':
        return 'Uploaded successfully! ✨';
      default:
        return 'Operation completed! ✨';
    }
  }

  /// Show snackbar with error message
  static void showErrorSnackbar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceAll('\n', ' ')),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Show snackbar with success message
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
