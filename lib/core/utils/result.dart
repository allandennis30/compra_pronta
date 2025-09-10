/// Resultado genérico para operações de repositório/serviço
///
/// Uso:
/// final result = await repo.getDataR();
/// result.when(
///   success: (data) { ... },
///   failure: (message, {code, exception}) { ... },
/// );
abstract class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, {int? code, Object? exception}) failure,
  }) {
    final self = this;
    if (self is Success<T>) {
      return success(self.data);
    } else if (self is Failure<T>) {
      return failure(self.message, code: self.code, exception: self.exception);
    }
    throw StateError('Unknown Result type');
  }

  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
  String? get errorOrNull => this is Failure<T> ? (this as Failure<T>).message : null;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final int? code;
  final Object? exception;

  const Failure(this.message, {this.code, this.exception});
}