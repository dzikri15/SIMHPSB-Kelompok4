// lib/services/chatbot_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import 'auth_service.dart';

class ChatbotService {
  static const String _endpoint =
      'https://simhp.my.id/chatbot/prabowo'; // langsung web, bukan /api

  final AuthService _auth = AuthService();

  Future<String> sendMessage(String message) async {
    final token = await _auth.getToken();

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] as String? ??
            'Maaf Kak, tidak ada respons dari HPSBBot.';
      } else {
        return 'Maaf Kak, server sedang sibuk (${response.statusCode}). Coba lagi ya.';
      }
    } catch (e) {
      return 'Maaf Kak, gagal menghubungi HPSBBot. Periksa koneksi internet kamu.';
    }
  }
}
