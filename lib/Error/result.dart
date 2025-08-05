class Result<T> {
  final T? value;
  final String errorMessage;
  final bool isSuccess;
  const Result(this.value, this.errorMessage, this.isSuccess);

  factory Result.ok(T value) {
    return Result(value, "", true);
  }

  factory Result.error(String errorMessage) {
    return Result(null, errorMessage, false);
  }

  // factory Result.error(Exception error) => Error(error);
}
