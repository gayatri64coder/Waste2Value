/// Custom failures and exceptions for clean domain/service error handling
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class FirestoreFailure extends Failure {
  const FirestoreFailure(super.message, {super.code});
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}
