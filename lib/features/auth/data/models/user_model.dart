import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user.dart';

/// Data model for User with Firestore serialization
class UserModel {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final String role;
  final String? cooperativeId;
  final String? collectionCentreId;
  final String? partnerId;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  
  const UserModel({
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
  
  /// Create UserModel from Firebase User and custom claims
  factory UserModel.fromFirebaseUser(
    firebase_auth.User firebaseUser,
    Map<String, dynamic>? customClaims,
  ) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      phoneNumber: firebaseUser.phoneNumber,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      role: customClaims?['role'] as String? ?? 'farmer',
      cooperativeId: customClaims?['cooperativeId'] as String?,
      collectionCentreId: customClaims?['collectionCentreId'] as String?,
      partnerId: customClaims?['partnerId'] as String?,
      emailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime,
      lastLogin: firebaseUser.metadata.lastSignInTime,
    );
  }
  
  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: data['role'] as String? ?? 'farmer',
      cooperativeId: data['cooperativeId'] as String?,
      collectionCentreId: data['collectionCentreId'] as String?,
      partnerId: data['partnerId'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }
  
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'cooperativeId': cooperativeId,
      'collectionCentreId': collectionCentreId,
      'partnerId': partnerId,
      'emailVerified': emailVerified,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }
  
  /// Convert to domain entity
  User toEntity() {
    return User(
      uid: uid,
      email: email,
      phoneNumber: phoneNumber,
      displayName: displayName,
      photoUrl: photoUrl,
      role: userRoleFromString(role),
      cooperativeId: cooperativeId,
      collectionCentreId: collectionCentreId,
      partnerId: partnerId,
      emailVerified: emailVerified,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }
  
  /// Create from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      role: user.role.value,
      cooperativeId: user.cooperativeId,
      collectionCentreId: user.collectionCentreId,
      partnerId: user.partnerId,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
      lastLogin: user.lastLogin,
    );
  }
}
