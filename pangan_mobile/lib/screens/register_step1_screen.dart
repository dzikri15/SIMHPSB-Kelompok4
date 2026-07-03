// lib/screens/register_step1_screen.dart

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'register_step2_screen.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterStep2Screen(
          name:                 _nameCtrl.text.trim(),
          email:                _emailCtrl.text.trim(),
          password:             _passCtrl.text,
          passwordConfirmation: _confirmCtrl.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Header
                Text(
                  'Daftar Akun',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Langkah 1 dari 2 — Buat akun masuk Anda',
                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),

                // Progress
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 32),

                // Nama
                _label('NAMA LENGKAP'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: _inputDecoration(context, 'Nama lengkap Anda'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 20),

                // Email
                _label('ALAMAT EMAIL'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: _inputDecoration(context, 'email@anda.com'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                    if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                _label('KATA SANDI'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: _inputDecoration(context, '••••••••', suffix: IconButton(
                    icon: Icon(
                      _obscurePass ? Icons.visibility_off : Icons.visibility,
                      color: theme.colorScheme.onSurfaceVariant, size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  )),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Kata sandi tidak boleh kosong';
                    if (v.length < 6) return 'Kata sandi minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Konfirmasi Password
                _label('KONFIRMASI KATA SANDI'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: _inputDecoration(context, '••••••••', suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: theme.colorScheme.onSurfaceVariant, size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  )),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
                    if (v != _passCtrl.text) return 'Kata sandi tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Tombol Lanjut
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _next,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text(
                      'Lanjut',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );

  InputDecoration _inputDecoration(BuildContext context, String hint, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: suffix,
      );
}
