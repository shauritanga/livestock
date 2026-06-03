import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  
  AuthRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Success(userModel?.toEntity());
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map(
      (userModel) => userModel?.toEntity(),
    );
  }
  
  @override
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(userModel.toEntity());
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<User>> signInWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signInWithPhoneAndPassword(
        phoneNumber: phoneNumber,
        password: password,
      );
      return Success(userModel.toEntity());
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Success(null);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
      return const Success(null);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<void>> sendPasswordResetSMS({
    required String phoneNumber,
  }) async {
    // TODO: Implement SMS password reset via Cloud Function
    return const Error(ServerFailure('SMS password reset not yet implemented'));
  }
  
  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Success(null);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<User>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final userModel = await remoteDataSource.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return Success(userModel.toEntity());
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Success(null);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<bool>> isEmailVerified() async {
    try {
      final isVerified = await remoteDataSource.isEmailVerified();
      return Success(isVerified);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<void>> refreshToken() async {
    try {
      await remoteDataSource.refreshToken();
      return const Success(null);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
}
