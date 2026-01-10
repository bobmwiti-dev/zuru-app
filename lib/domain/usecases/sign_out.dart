import '../../data/repositories/auth_repository.dart';

/// Use case for signing out
abstract class SignOut {
  /// Execute the use case
  Future<void> call();
}

/// Implementation of SignOut use case
class SignOutImpl implements SignOut {
  final AuthRepository _repository;

  SignOutImpl(this._repository);

  @override
  Future<void> call() async {
    return await _repository.signOut();
  }
}