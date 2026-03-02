/// A generic class to handle API responses across the application.
class ApiResponse<T> {
  /// Whether the request was successful.
  final bool success;

  /// The data returned by the API if successful.
  final T? data;

  /// An error message if the request failed.
  final String? errorMessage;

  /// The HTTP status code of the response.
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  /// Factory constructor for successful responses.
  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse(success: true, data: data, statusCode: statusCode);
  }

  /// Factory constructor for error responses.
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      errorMessage: message,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, errorMessage: $errorMessage, statusCode: $statusCode)';
  }
}
