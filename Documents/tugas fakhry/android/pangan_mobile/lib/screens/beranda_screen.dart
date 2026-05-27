import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_top_bar.dart';

class BerandaScreen extends StatelessWidget {
  final Function(int)? onNavigateToScreen;

  const BerandaScreen({
    super.key,
    this.onNavigateToScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat pagi, Petugas',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            const Text(
              'Beranda',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),

            // Total Petani Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL PETANI TERDATA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1,284',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: AppColors.onSurface,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.group, color: AppColors.primary, size: 32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Panen & Gudang Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: AppColors.onSurfaceVariant),
                            SizedBox(width: 6),
                            Text(
                              'PANEN HARI INI',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(color: AppColors.onSurface),
                            children: [
                              TextSpan(
                                text: '4.2 ',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: 'Ton',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '+12% dari kemarin',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warehouse_outlined,
                                size: 14, color: AppColors.onPrimaryContainer),
                            SizedBox(width: 6),
                            Text(
                              'GUDANG',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '88%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.88,
                          backgroundColor: AppColors.onPrimaryContainer.withOpacity(0.2),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(AppColors.onPrimaryContainer),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Akses Cepat
            const Text(
              'AKSES CEPAT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            _aksesItem(
              Icons.person_add_alt,
              'Data Petani',
              'Registrasi & monitoring profil',
              1, // PETANI screen index
            ),
            const SizedBox(height: 10),
            _aksesItem(
              Icons.add_chart,
              'Input Panen',
              'Catat hasil produksi baru',
              2, // PANEN screen index
            ),
            const SizedBox(height: 10),
            _aksesItem(
              Icons.warehouse_outlined,
              'Stok Gudang',
              'Cek ketersediaan logistik',
              3, // GUDANG screen index
            ),
            const SizedBox(height: 24),

            // Pembaruan Lokasi Banner
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'PEMBARUAN LOKASI',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Wilayah Sektor Utara',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Semua aktivitas dalam pantauan normal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aksesItem(
    IconData icon,
    String title,
    String subtitle,
    int screenIndex,
  ) {
    return _AksesItemWidget(
      icon: icon,
      title: title,
      subtitle: subtitle,
      screenIndex: screenIndex,
      onTap: onNavigateToScreen,
    );
  }
}

class _AksesItemWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int screenIndex;
  final Function(int)? onTap;

  const _AksesItemWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.screenIndex,
    this.onTap,
  });

  @override
  State<_AksesItemWidget> createState() => _AksesItemWidgetState();
}

class _AksesItemWidgetState extends State<_AksesItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call(widget.screenIndex);
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: AppColors.onSurface, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

