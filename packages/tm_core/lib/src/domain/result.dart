sealed class Result<T, E> {
  const Result();

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;
}

final class Success<T, E> extends Result<T, E> {
  const Success(this.value);

  final T value;
}

final class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);

  final E error;
}

extension ResultX<T, E> on Result<T, E> {
  T? get value => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  E? get error => switch (this) {
    Failure(:final error) => error,
    Success() => null,
  };

  Result<U, E> map<U>(U Function(T) f) => switch (this) {
    Success(:final value) => Success(f(value)),
    Failure(:final error) => Failure(error),
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) {
    final result = this;
    if (result is Success<T, E>) {
      return onSuccess(result.value);
    }
    return onFailure((result as Failure<T, E>).error);
  }
}
