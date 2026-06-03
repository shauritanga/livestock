import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Use case for sending password reset SMS
class SendPasswordResetSMS {
  final AuthRepository repository;
  
  SendPasswordResetSMS(this.repository);
  
  /// Execute the use case
  Future<Result<void>> call({
    required String phoneNumber,
  }) async {
    return await repository.sendPasswordResetSMS(phoneNumber: phoneNumber);
  }
}
