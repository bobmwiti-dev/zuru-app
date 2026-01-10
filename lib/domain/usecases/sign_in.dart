import '../../data/repositories/auth_repository.dart';

/// Use case for signing in
abstract class SignIn {
  /// Execute the use case
  Future<void> call(String email, String password);
}

/// Implementation of SignIn use case
class SignInImpl implements SignIn {
  final AuthRepository _repository;

  SignInImpl(this._repository);

  @override
  Future<void> call(String email, String password) async {
    await _repository.signIn(email, password);
  }
}