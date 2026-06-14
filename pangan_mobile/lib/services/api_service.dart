// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Otomatis refresh token jika 401, lalu retry sekali.
  Future<http.Response> _handleResponse(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    final headers = await _headers();
    var response = await request(headers);

    if (response.statusCode == 401) {
      try {
        final newToken = await _auth.refreshToken();
        final retryHeaders = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $newToken',
        };
        response = await request(retryHeaders);
      } on AuthException {
        rethrow; // token expired tak bisa refresh → lempar ke UI
      }
    }
    return response;
  }

  Future<dynamic> get(String path) async {
    final response = await _handleResponse(
      (h) => http.get(Uri.parse('${AppConstants.baseUrl}/$path'), headers: h),
    );
    return _parse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await _handleResponse(
      (h) => http.post(
        Uri.parse('${AppConstants.baseUrl}/$path'),
        headers: h,
        body: jsonEncode(body),
      ),
    );
    return _parse(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await _handleResponse(
      (h) => http.put(
        Uri.parse('${AppConstants.baseUrl}/$path'),
        headers: h,
        body: jsonEncode(body),
      ),
    );
    return _parse(response);
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    final response = await _handleResponse(
      (h) => http.patch(
        Uri.parse('${AppConstants.baseUrl}/$path'),
        headers: h,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return _parse(response);
  }

  Future<void> delete(String path) async {
    final response = await _handleResponse(
      (h) => http.delete(
          Uri.parse('${AppConstants.baseUrl}/$path'), headers: h),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException('Gagal menghapus data (${response.statusCode})');
    }
  }

  /// Upload file dengan multipart form-data
  /// 
  /// Parameters:
  ///   - path: API endpoint path
  ///   - file: File to upload
  ///   - fileFieldName: Form field name for the file (default: 'file')
  ///   - additionalFields: Other form fields to include
  Future<dynamic> uploadMultipart(
    String path, {
    required List<int> fileBytes,
    required String fileName,
    required String fileFieldName,
    Map<String, String>? additionalFields,
  }) async {
    final token = await AuthService().getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}/$path'),
    );

    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Add file (works on web & native; sets contentType from extension)
    request.files.add(
      http.MultipartFile.fromBytes(
        fileFieldName,
        fileBytes,
        filename: fileName,
        contentType: _mimeTypeFor(fileName),
      ),
    );

    // Add additional fields
    if (additionalFields != null) {
      request.fields.addAll(additionalFields);
    }

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    // Handle 401 Unauthorized - try refreshing token
    if (responseData.statusCode == 401) {
      try {
        final newToken = await AuthService().refreshToken();
        if (newToken.isNotEmpty) {
          // Retry with new token
          request.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await request.send();
          final retryData = await http.Response.fromStream(retryResponse);
          return _parse(retryData);
        }
      } catch (_) {
        // If refresh fails, return original error
      }
    }

    return _parse(responseData);
  }

  MediaType _mimeTypeFor(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  dynamic _parse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    String message = 'Terjadi kesalahan (${response.statusCode})';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message'] as String? ??
          body['error'] as String? ??
          message;
    } catch (_) {}
    throw ApiException(message, statusCode: response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}