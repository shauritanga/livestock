import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Remote data source for authentication using Firebase
abstract class AuthRemoteDataSource {
  /// Get current Firebase user
  Future<UserModel?> getCurrentUser();
  
  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;
  
  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  /// Sign in with phone and password
  Future<UserModel> signInWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  });
  
  /// Sign out
  Future<void> signOut();
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email});
  
  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  /// Update profile
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  });
  
  /// Send email verification
  Future<void> sendEmailVerification();
  
  /// Check if email is verified
  Future<bool> isEmailVerified();
  
  /// Refresh token
  Future<void> refreshToken();
  
  /// Get custom claims for user
  Future<Map<String, dynamic>?> getCustomClaims();
}

/// Implementation of AuthRemoteDataSource using Firebase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  
  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });
  
  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) return null;
      
      final customClaims = await getCustomClaims();
      return UserModel.fromFirebaseUser(firebaseUser, customClaims);
    } catch (e) {
      throw ServerException('Failed to get current user: $e');
    }
  }
  
  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      final customClaims = await getCustomClaims();
      return UserModel.fromFirebaseUser(firebaseUser, customClaims);
    });
  }
  
  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthenticationException('Sign in failed');
      }
      
      // Update last login in Firestore
      await _updateLastLogin(credential.user!.uid);
      
      final customClaims = await getCustomClaims();
      return UserModel.fromFirebaseUser(credential.user!, customClaims);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthenticationException(e.message ?? 'Authentication failed');
    } catch (e) {
      throw ServerException('Sign in failed: $e');
    }
  }
  
  @override
  Future<UserModel> signInWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Firebase doesn't support phone + password directly
      // We need to use email associated with phone or custom implementation
      // For now, we'll look up email from Firestore and use email sign in
      
      final userDoc = await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (userDoc.docs.isEmpty) {
        throw AuthenticationException('User not found');
      }
      
      final email = userDoc.docs.first.data()['email'] as String?;
      if (email == null) {
        throw AuthenticationException('Email not found for this phone number');
      }
      
      return await signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ServerException('Sign in with phone failed: $e');
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('Sign out failed: $e');
    }
  }
  
  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthenticationException(e.message ?? 'Failed to send reset email');
    } catch (e) {
      throw ServerException('Failed to send reset email: $e');
    }
  }
  
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationException('No user signed in');
      }
      
      // Re-authenticate user
      final email = user.email;
      if (email == null) {
        throw AuthenticationException('User email not found');
      }
      
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthenticationException(e.message ?? 'Failed to change password');
    } catch (e) {
      throw ServerException('Failed to change password: $e');
    }
  }
  
  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationException('No user signed in');
      }
      
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);
      
      // Update in Firestore
      await firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });
      
      await user.reload();
      final updatedUser = firebaseAuth.currentUser!;
      
      final customClaims = await getCustomClaims();
      return UserModel.fromFirebaseUser(updatedUser, customClaims);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthenticationException(e.message ?? 'Failed to update profile');
    } catch (e) {
      throw ServerException('Failed to update profile: $e');
    }
  }
  
  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationException('No user signed in');
      }
      
      await user.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthenticationException(e.message ?? 'Failed to send verification');
    } catch (e) {
      throw ServerException('Failed to send verification: $e');
    }
  }
  
  @override
  Future<bool> isEmailVerified() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return false;
      
      await user.reload();
      return firebaseAuth.currentUser?.emailVerified ?? false;
    } catch (e) {
      throw ServerException('Failed to check email verification: $e');
    }
  }
  
  @override
  Future<void> refreshToken() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationException('No user signed in');
      }
      
      await user.getIdToken(true);
    } catch (e) {
      throw ServerException('Failed to refresh token: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>?> getCustomClaims() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;
      
      final idTokenResult = await user.getIdTokenResult();
      return idTokenResult.claims;
    } catch (e) {
      throw ServerException('Failed to get custom claims: $e');
    }
  }
  
  /// Update last login timestamp in Firestore
  Future<void> _updateLastLogin(String uid) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Non-critical, just log
      print('Failed to update last login: $e');
    }
  }
}
