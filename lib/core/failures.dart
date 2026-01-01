sealed class Failure {
  const Failure(this.message, {this.cause});

  final String message;
  final Object? cause;
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause});
}

class ParsingFailure extends Failure {
  const ParsingFailure(super.message, {super.cause});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause});
}
