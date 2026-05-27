// lib/core/constants.dart

class AppConstants {
  // ── Ganti dengan IP/domain server Laravel kamu ──────────────────────
  // Emulator Android  : http://10.0.2.2:8000/api
  // Perangkat fisik   : http://<IP-LAN>:8000/api
  // Production        : https://yourdomain.com/api
  static const String baseUrl = 'http://localhost:8000/api';

  // SharedPreferences keys
  static const String tokenKey = 'jwt_token';
  static const String userKey  = 'user_data';
}
