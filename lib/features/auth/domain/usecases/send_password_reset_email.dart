import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Use case for sending password reset email
class SendPasswordResetEmail {
  final AuthRepository repository;
  
  SendPasswordResetEmail(this.repository);
  
  /// Execute the use case
  Future<Result<void>> call({
    required String email,
  }) async {
    return await repository.sendPasswordResetEmail(email: email);
  }
}
