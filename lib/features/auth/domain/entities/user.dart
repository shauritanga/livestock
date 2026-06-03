import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user in the system
class User extends Equatable {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final String? cooperativeId;
  final String? collectionCentreId;
  final String? partnerId;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  
  const User({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    required this.role,
    this.cooperativeId,
    this.collectionCentreId,
    this.partnerId,
    this.emailVerified = false,
    this.createdAt,
    this.lastLogin,
  });
  
  /// Check if user is a system administrator
  bool get isSystemAdmin => role == UserRole.systemAdmin;
  
  /// Check if user is a cooperative manager
  bool get isCooperativeManager => role == UserRole.cooperativeManager;
  
  /// Check if user is a collection agent
  bool get isCollectionAgent => role == UserRole.collectionAgent;
  
  /// Check if user is a farmer
  bool get isFarmer => role == UserRole.farmer;
  
  /// Check if user is a financial partner
  bool get isFinancialPartner => role == UserRole.financialPartner;
  
  /// Check if user is an insurance partner
  bool get isInsurancePartner => role == UserRole.insurancePartner;
  
  /// Check if user has access to cooperative data
  bool get hasCooperativeAccess => cooperativeId != null;
  
  /// Check if user has access to collection centre data
  bool get hasCollectionCentreAccess => collectionCentreId != null;
  
  @override
  List<Object?> get props => [
        uid,
        email,
        phoneNumber,
        displayName,
        photoUrl,
        role,
        cooperativeId,
        collectionCentreId,
        partnerId,
        emailVerified,
        createdAt,
        lastLogin,
      ];
  
  /// Create a copy of User with updated fields
  User copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    String? cooperativeId,
    String? collectionCentreId,
    String? partnerId,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      collectionCentreId: collectionCentreId ?? this.collectionCentreId,
      partnerId: partnerId ?? this.partnerId,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

/// User roles in the system
enum UserRole {
  systemAdmin,
  cooperativeManager,
  collectionAgent,
  farmer,
  financialPartner,
  insurancePartner,
}

/// Extension to convert UserRole to string
extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.systemAdmin:
        return 'system_admin';
      case UserRole.cooperativeManager:
        return 'cooperative_manager';
      case UserRole.collectionAgent:
        return 'collection_agent';
      case UserRole.farmer:
        return 'farmer';
      case UserRole.financialPartner:
        return 'financial_partner';
      case UserRole.insurancePartner:
        return 'insurance_partner';
    }
  }
  
  /// Get user-friendly display name
  String get displayName {
    switch (this) {
      case UserRole.systemAdmin:
        return 'System Administrator';
      case UserRole.cooperativeManager:
        return 'Cooperative Manager';
      case UserRole.collectionAgent:
        return 'Collection Agent';
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.financialPartner:
        return 'Financial Partner';
      case UserRole.insurancePartner:
        return 'Insurance Partner';
    }
  }
}

/// Parse UserRole from string
UserRole userRoleFromString(String role) {
  switch (role) {
    case 'system_admin':
      return UserRole.systemAdmin;
    case 'cooperative_manager':
      return UserRole.cooperativeManager;
    case 'collection_agent':
      return UserRole.collectionAgent;
    case 'farmer':
      return UserRole.farmer;
    case 'financial_partner':
      return UserRole.financialPartner;
    case 'insurance_partner':
      return UserRole.insurancePartner;
    default:
      throw ArgumentError('Invalid user role: $role');
  }
}
