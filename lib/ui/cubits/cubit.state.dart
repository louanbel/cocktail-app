sealed class CubitState<T> {
  const CubitState();
}

class InitialState<T> extends CubitState<T> {
  const InitialState();
}

class LoadingState<T> extends CubitState<T> {
  const LoadingState();
}

class SuccessState<T> extends CubitState<T> {
  const SuccessState({
    required this.data,
  });

  final T data;
}

class FailureState<T> extends CubitState<T> {
  const FailureState({
    required this.message,
  });

  final String message;
}