// lib/core/constants.dart

class AppConstants {
  // ── Ganti dengan IP/domain server Laravel kamu ──────────────────────
  // Emulator Android  : http://10.0.2.2:8000/api
  // Perangkat fisik   : http://<IP-LAN>:8000/api
  // Production        : https://yourdomain.com/api

  // ⚠️ PENTING: localhost hanya bekerja di browser. Android perlu IP atau special alias
  // Ubah ke IP LAN kamu (contoh: 192.168.1.100) atau 10.0.2.2 untuk emulator
  static const String baseUrl = 'http://192.168.1.4/api';

  // ── Storage URLs ──────────────────────────────────────────────────
  // Untuk akses file dari storage/app/public, lewat route api/file/{path}
  // agar response memiliki header CORS (diperlukan untuk Flutter Web).
  // Format: http://127.0.0.1:8000/api/file/bukti-distribusi/filename.jpg
  static String get storageUrl => '$baseUrl/file';

  // SharedPreferences keys
  static const String tokenKey = 'jwt_token';
  static const String userKey  = 'user_data';

  /// Build complete URL untuk file di storage
  /// Input: "bukti-distribusi/1781358313_26bd614233f90.png"
  /// Output: "http://localhost:8000/storage/bukti-distribusi/1781358313_26bd614233f90.png"
  static String getStorageFileUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path; // Sudah full URL
    return '$storageUrl/$path';
  }
}