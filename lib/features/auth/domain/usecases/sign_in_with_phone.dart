import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with phone number and password
class SignInWithPhone {
  final AuthRepository repository;
  
  SignInWithPhone(this.repository);
  
  /// Execute the use case
  Future<Result<User>> call({
    required String phoneNumber,
    required String password,
  }) async {
    return await repository.signInWithPhoneAndPassword(
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}
