/// User profile model representing user's personal information
/// Contains all profile fields stored in the backend
class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String streetAddress;
  final String city;
  final String postalCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.streetAddress,
    required this.city,
    required this.postalCode,
    this.createdAt,
    this.updatedAt,
  });

  /// Create UserProfile from JSON response
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      phone:
          json['phone']?.toString() ?? json['phone_number']?.toString() ?? '',
      streetAddress:
          json['street_address']?.toString() ??
          json['address']?.toString() ??
          '',
      city: json['city']?.toString() ?? '',
      postalCode:
          json['postal_code']?.toString() ?? json['zip_code']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  /// Convert UserProfile to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'street_address': streetAddress,
      'city': city,
      'postal_code': postalCode,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy of UserProfile with updated fields
  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? streetAddress,
    String? city,
    String? postalCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display name (full name or email if full name is empty)
  String get displayName {
    return fullName.isNotEmpty ? fullName : email;
  }

  /// Get formatted address
  String get formattedAddress {
    final parts = <String>[];
    if (streetAddress.isNotEmpty) parts.add(streetAddress);
    if (city.isNotEmpty) parts.add(city);
    if (postalCode.isNotEmpty) parts.add(postalCode);
    return parts.join(', ');
  }

  /// Check if profile is complete
  bool get isComplete {
    return fullName.isNotEmpty &&
        phone.isNotEmpty &&
        streetAddress.isNotEmpty &&
        city.isNotEmpty &&
        postalCode.isNotEmpty;
  }

  /// Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'UserProfile{id: $id, email: $email, fullName: $fullName, phone: $phone, address: $formattedAddress}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.phone == phone &&
        other.streetAddress == streetAddress &&
        other.city == city &&
        other.postalCode == postalCode;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      fullName,
      phone,
      streetAddress,
      city,
      postalCode,
    );
  }
}
