class APIResponse<T>{
  final Object? error;
  final int? statusCode;
  final T? body;
  final dynamic errorBody;

  const APIResponse({this.statusCode, this.body, this.error, this.errorBody});
}