import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting the current authenticated user
class GetCurrentUser {
  final AuthRepository repository;
  
  GetCurrentUser(this.repository);
  
  /// Execute the use case
  Future<Result<User?>> call() async {
    return await repository.getCurrentUser();
  }
}
