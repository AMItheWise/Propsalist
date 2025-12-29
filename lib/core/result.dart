import 'package:proposal_writer/core/failures.dart';

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure error) failure,
  });

  bool get isSuccess => this is Success<T>;
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure error) failure,
  }) {
    return success(data);
  }
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.error);

  final Failure error;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure error) failure,
  }) {
    return failure(error);
  }
}
