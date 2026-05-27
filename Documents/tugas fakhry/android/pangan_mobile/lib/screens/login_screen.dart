// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import '../main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading       = false;
  bool _obscure       = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService().login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5EC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.shield, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'SIMHPSB',
                style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900,
                  color: AppColors.primary, letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sistem Informasi Manajemen Hasil Panen dan Sumber Bakti',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 48),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Selamat Datang',
                    style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w900,
                      color: AppColors.onSurface,
                    )),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Masuk untuk mengelola data lapangan Anda.',
                    style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
              ),
              const SizedBox(height: 32),

              // Error banner
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.4)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],

              // Email
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('ALAMAT EMAIL',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      letterSpacing: 1.2, color: AppColors.onSurfaceVariant,
                    )),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'nama@petugas.id',
                  hintStyle: const TextStyle(color: AppColors.outline),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('KATA SANDI',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        letterSpacing: 1.2, color: AppColors.onSurfaceVariant,
                      )),
                  GestureDetector(
                    onTap: () {},
                    child: const Text('Lupa Sandi?',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: AppColors.outline),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.outline,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 32),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _login,
                  icon: _loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.login),
                  label: Text(
                    _loading ? 'Memproses...' : 'Masuk ke Akun',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                  children: [
                    TextSpan(text: 'Belum memiliki akun? '),
                    TextSpan(
                      text: 'Hubungi Admin',
                      style: TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              const Text('MITRA LAPANGAN',
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    letterSpacing: 1.5, color: AppColors.onSurfaceVariant,
                  )),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _mitraIcon(Icons.grid_view),
                  const SizedBox(width: 20),
                  _mitraIcon(Icons.agriculture),
                  const SizedBox(width: 20),
                  _mitraIcon(Icons.eco),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mitraIcon(IconData icon) => Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      );
}
