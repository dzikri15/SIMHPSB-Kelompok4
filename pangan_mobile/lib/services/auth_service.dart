// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

class AuthService {
  // ── Singleton ─────────────────────────────────────────────────────────
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ── Token helpers ─────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── User cache ────────────────────────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  // ── API calls ─────────────────────────────────────────────────────────

  /// Login → returns [UserModel] on success, throws [AuthException] on failure.
  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final token = body['token'] as String;
      final user  = UserModel.fromJson(body['user'] as Map<String, dynamic>);
      await saveToken(token);
      await saveUser(user);
      return user;
    } else if (response.statusCode == 403 && body['error'] == 'akun_nonaktif') {
      throw const AuthException(
        'Akun Anda belum diaktifkan oleh admin.\nSilakan hubungi admin untuk aktivasi.',
      );
    } else if (response.statusCode == 401) {
      throw const AuthException('Email atau kata sandi salah.');
    } else {
      throw AuthException('Terjadi kesalahan server (${response.statusCode}).');
    }
  }

  /// Register petani dari mobile — 2 langkah digabung jadi 1 request.
  /// Tidak mengembalikan token; akun menunggu aktivasi admin.
  Future<void> registerPetani({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String alamat,
    String? telepon,
    int? luasLahan,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/register-petani'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name':                  name,
        'email':                 email,
        'password':              password,
        'password_confirmation': passwordConfirmation,
        'alamat':                alamat,
        'telepon':               telepon,
        'luas_lahan':            luasLahan,
      }),
    );

    if (response.statusCode == 201) {
      return; // Sukses
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 422) {
      final errors = body['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final firstMsg = (errors.values.first as List).first as String;
        throw AuthException(firstMsg);
      }
      throw AuthException(body['message'] as String? ?? 'Validasi gagal.');
    }

    throw AuthException('Terjadi kesalahan server (${response.statusCode}).');
  }

  /// Logout → invalidates token on server, then clears local storage.
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('${AppConstants.baseUrl}/auth/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      } catch (_) {
        // Even if the request fails, clear local token anyway.
      }
    }
    await deleteToken();
  }

  /// Refresh JWT token. Returns new token string or throws.
  Future<String> refreshToken() async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/refresh'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final newToken =
          (jsonDecode(response.body) as Map<String, dynamic>)['token'] as String;
      await saveToken(newToken);
      return newToken;
    } else {
      await deleteToken();
      throw const AuthException('Sesi telah habis. Silakan login kembali.');
    }
  }

  /// Fetch current user from /auth/me.
  Future<UserModel> me() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final user = UserModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
      await saveUser(user);
      return user;
    } else {
      throw const AuthException('Gagal memuat data pengguna.');
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
