// lib/screens/register_step2_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';

class RegisterStep2Screen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterStep2Screen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _alamatCtrl   = TextEditingController();
  final _teleponCtrl  = TextEditingController();
  final _luasCtrl     = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  bool    _loading = false;
  String? _error;

  @override
  void dispose() {
    _alamatCtrl.dispose();
    _teleponCtrl.dispose();
    _luasCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      await AuthService().registerPetani(
        name:                 widget.name,
        email:                widget.email,
        password:             widget.password,
        passwordConfirmation: widget.passwordConfirmation,
        alamat:               _alamatCtrl.text.trim(),
        telepon:              _teleponCtrl.text.trim().isEmpty ? null : _teleponCtrl.text.trim(),
        luasLahan:            _luasCtrl.text.trim().isEmpty ? null : int.tryParse(_luasCtrl.text.trim()),
      );

      if (!mounted) return;

      // Kembali ke halaman login, lalu tampilkan snackbar
      Navigator.of(context).popUntil((route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pendaftaran berhasil! Akun Anda sedang menunggu aktivasi admin.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Tidak dapat terhubung ke server. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                  'Data Petani',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Langkah 2 dari 2 — Isi informasi lahan Anda',
                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),

                // Progress
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 32),

                // Info user (readonly)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              widget.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Error banner
                if (_error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                ],

                // Alamat
                _label('ALAMAT LENGKAP *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _alamatCtrl,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: _inputDecoration(context, 'Desa, Kecamatan, Kabupaten...'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Alamat tidak boleh kosong' : null,
                ),
                const SizedBox(height: 20),

                // Telepon
                _label('NO. TELEPON / HP'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _teleponCtrl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: _inputDecoration(context, '0812-xxxx-xxxx (opsional)'),
                ),
                const SizedBox(height: 20),

                // Luas Lahan
                _label('LUAS LAHAN (m²)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _luasCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: _inputDecoration(context, 'Contoh: 5000 (opsional)'),
                ),
                const SizedBox(height: 20),

                // Komoditas (readonly)
                _label('KOMODITAS UTAMA'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.grass, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Padi',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Otomatis',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary),
                            ),
                          )
                        : const Icon(Icons.how_to_reg),
                    label: Text(
                      _loading ? 'Mendaftar...' : 'Daftar Sekarang',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

                // Info box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.onSurfaceVariant, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Setelah mendaftar, akun Anda akan diverifikasi oleh admin. Anda akan bisa login setelah admin mengaktifkan akun Anda.',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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

  InputDecoration _inputDecoration(BuildContext context, String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
}
