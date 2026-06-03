import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Use case for changing user password
class ChangePassword {
  final AuthRepository repository;
  
  ChangePassword(this.repository);
  
  /// Execute the use case
  Future<Result<void>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
