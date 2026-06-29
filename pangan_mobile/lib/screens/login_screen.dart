
// lib/screens/login_screen.dart
 
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import '../main.dart';
import '../main_shell.dart';
import '../petani_shell.dart';
 
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
      final user = await AuthService().login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (!mounted) return;
      if (user.isAdmin) {
        await AuthService().logout();
        setState(() => _error = 'Akun admin tidak dapat menggunakan aplikasi mobile.');
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => user.isPetani ? const PetaniShell() : const MainShell(),
        ),
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
    final isDark = themeNotifier.value == ThemeMode.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dark Mode Toggle Button
              Align(
                alignment: Alignment.centerRight,
                child: ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (_, mode, __) => IconButton(
                    onPressed: () {
                      themeNotifier.value = 
                        mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                    },
                    icon: Icon(
                      mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    tooltip: mode == ThemeMode.dark ? 'Light Mode' : 'Dark Mode',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withValues(alpha: 0.8),
                      secondaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.network(
                    'https://raw.githubusercontent.com/NoahMikhailovna/foto/c45c72f9adca95001eefebd49d7581e89d0de508/padi_logo_fitted.svg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
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
              Text(
                'Sistem Informasi Monitoring Hasil Panen dan Stok Beras Berbasis Mobile',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 48),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Selamat Datang',
                    style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Masuk untuk mengelola data lapangan Anda.',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
              const SizedBox(height: 32),
 
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
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],
 
              // Email
              Align(
                alignment: Alignment.centerLeft,
                child: Text('ALAMAT EMAIL',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      letterSpacing: 1.2, color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'nama@petugas.id',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text('KATA SANDI',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      letterSpacing: 1.2, color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                      ? SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, 
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary))
                      )
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
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  children: const [
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
              Text('MITRA LAPANGAN',
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    letterSpacing: 1.5, color: Theme.of(context).colorScheme.onSurfaceVariant,
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
