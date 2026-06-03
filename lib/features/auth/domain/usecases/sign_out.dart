import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing out the current user
class SignOut {
  final AuthRepository repository;
  
  SignOut(this.repository);
  
  /// Execute the use case
  Future<Result<void>> call() async {
    return await repository.signOut();
  }
}
