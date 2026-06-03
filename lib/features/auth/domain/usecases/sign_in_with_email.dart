import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInWithEmail {
  final AuthRepository repository;
  
  SignInWithEmail(this.repository);
  
  /// Execute the use case
  Future<Result<User>> call({
    required String email,
    required String password,
  }) async {
    return await repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
