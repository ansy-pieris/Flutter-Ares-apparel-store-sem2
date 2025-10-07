import '../services/api_service.dart';

/// User model for authentication and profile management
/// Handles user data from Laravel API responses
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;
  final String? avatar;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.avatar,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.preferences = const {},
  });

  /// Check if user email is verified
  bool get isEmailVerified => emailVerifiedAt != null;

  /// Get full name for display
  String get displayName => name.isNotEmpty ? name : email;

  /// Get full address string
  String get fullAddress {
    final parts =
        [
          address,
          city,
          state,
          country,
          zipCode,
        ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.join(', ');
  }

  /// Get avatar URL with API base URL
  String get avatarUrl {
    if (avatar == null || avatar!.isEmpty) return '';
    return ApiService.getFullImageUrl(avatar!);
  }

  /// Create copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    String? avatar,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      avatar: avatar ?? this.avatar,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Convert User to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'avatar': avatar,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'preferences': preferences,
    };
  }

  /// Create User from JSON API response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      zipCode: json['zip_code']?.toString() ?? json['zipcode']?.toString(),
      avatar: json['avatar']?.toString(),
      emailVerifiedAt: _parseDateTime(json['email_verified_at']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
      preferences: _parsePreferences(json['preferences']),
    );
  }

  // Helper methods for safe parsing
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static Map<String, dynamic> _parsePreferences(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email}';
  }
}
