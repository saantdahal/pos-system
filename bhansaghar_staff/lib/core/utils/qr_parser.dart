/// Utility class to parse QR code values and extract invite IDs
class QRParser {
  /// Extracts the invite ID from a QR code value
  /// Handles both full URLs and plain invite IDs
  ///
  /// Examples:
  /// - "http://localhost:3000/claim-invite/68d59d60-1dd7-48d7-8f57-2d1806ece6f6" -> "68d59d60-1dd7-48d7-8f57-2d1806ece6f6"
  /// - "68d59d60-1dd7-48d7-8f57-2d1806ece6f6" -> "68d59d60-1dd7-48d7-8f57-2d1806ece6f6"
  static String extractInviteId(String qrValue) {
    if (qrValue.isEmpty) return '';

    // Check if it's a URL
    if (qrValue.contains('claim-invite')) {
      final parts = qrValue.split('/');
      if (parts.isNotEmpty) {
        return parts.last; // Get the last part which should be the ID
      }
    }

    // If it's already just an ID, return as is
    return qrValue;
  }

  /// Validates if the given string looks like a valid invite ID (UUID format)
  static bool isValidInviteId(String inviteId) {
    // UUID v4 pattern: 8-4-4-4-12 hex characters
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(inviteId);
  }
}
