import 'failures.dart';

class Result<T> {
  final T? data;
  final Failure? failure;

  Result._({this.data, this.failure});

  factory Result.success(T data) => Result._(data: data);
  factory Result.error(Failure failure) => Result._(failure: failure);

  bool get isSuccess => failure == null;
  bool get isError => failure != null;

  R fold<R>(R Function(Failure) onError, R Function(T) onSuccess) {
    if (isError) {
      return onError(failure!);
    } else {
      return onSuccess(data as T);
    }
  }
}
