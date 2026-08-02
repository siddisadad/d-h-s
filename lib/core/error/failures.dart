abstract class Failure {
  final String message;
  Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  ServerFailure([String message = 'Server failure occurred']) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure([String message = 'Cache failure occurred']) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure([String message = 'No internet connection']) : super(message);
}
