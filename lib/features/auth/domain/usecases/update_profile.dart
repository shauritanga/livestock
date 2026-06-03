import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for updating user profile
class UpdateProfile {
  final AuthRepository repository;
  
  UpdateProfile(this.repository);
  
  /// Execute the use case
  Future<Result<User>> call({
    String? displayName,
    String? photoUrl,
  }) async {
    return await repository.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
