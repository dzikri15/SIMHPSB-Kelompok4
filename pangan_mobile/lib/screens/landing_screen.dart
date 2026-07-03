// lib/screens/landing_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  final LiquidController _liquidController = LiquidController();
  int _currentPage = 0;

  late AnimationController _hintController;
  late Animation<double> _hintOpacity;

  static const List<_LandingPageData> _pages = [
    _LandingPageData(
      backgroundGradient: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      accentColor: Color(0xFFA5D6A7),
      iconData: Icons.grass_rounded,
      tag: 'PANTAU PANEN',
      title: 'Monitoring\nHasil Panen',
      subtitle:
          'Lacak produktivitas lahan pertanian Anda secara real-time. '
          'Data akurat langsung dari lapangan ke genggaman tangan.',
    ),
    _LandingPageData(
      backgroundGradient: [Color(0xFF1A237E), Color(0xFF283593)],
      accentColor: Color(0xFF90CAF9),
      iconData: Icons.warehouse_rounded,
      tag: 'KELOLA STOK',
      title: 'Manajemen\nStok Beras',
      subtitle:
          'Pantau kapasitas gudang dan distribusi stok beras dengan '
          'sistem informasi terpadu yang mudah digunakan.',
    ),
    _LandingPageData(
      backgroundGradient: [Color(0xFFBF360C), Color(0xFFD84315)],
      accentColor: Color(0xFFFFCC80),
      iconData: Icons.notifications_active_rounded,
      tag: 'ALERT STOK',
      title: 'Notifikasi\nStok Kritis',
      subtitle:
          'Terima peringatan otomatis saat stok beras mendekati batas minimum. '
          'Selalu siap sebelum kehabisan.',
    ),
    _LandingPageData(
      backgroundGradient: [Color(0xFF3A694A), Color(0xFF224E33)],
      accentColor: Color(0xFFBDF0C6),
      iconData: Icons.rocket_launch_rounded,
      tag: 'SIAP MULAI',
      title: 'Satu Platform,\nSemua Solusi',
      subtitle:
          'SIMHP hadir untuk memperkuat ketahanan pangan nasional '
          'dengan teknologi digital yang inovatif.',
      isLast: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _hintOpacity = CurvedAnimation(
      parent: _hintController,
      curve: Curves.easeOut,
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _hintController.forward();
    });
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            pages: _pages
                .asMap()
                .entries
                .map((e) => _buildPage(context, e.key, e.value))
                .toList(),
            liquidController: _liquidController,
            enableLoop: false,
            fullTransitionValue: 600,
            waveType: WaveType.liquidReveal,
            enableSideReveal: false,
            onPageChangeCallback: (page) {
              setState(() => _currentPage = page);
              if (!_hintController.isCompleted) {
                _hintController.forward();
              }
            },
          ),

          // Dots + hint
          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => _buildDot(i),
                  ),
                ),
                const SizedBox(height: 12),
                if (_currentPage < _pages.length - 1)
                  FadeTransition(
                    opacity: ReverseAnimation(_hintOpacity),
                    child: Text(
                      'Geser ›',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, int index, _LandingPageData data) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.backgroundGradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Skip button
              SizedBox(
                height: 48,
                child: !data.isLast
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _liquidController.jumpToPage(
                              page: _pages.length - 1,
                            );
                          },
                          child: Text(
                            'Lewati',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const Spacer(),

              // Icon card
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  data.iconData,
                  color: data.accentColor,
                  size: 48,
                ),
              ),

              const SizedBox(height: 36),

              // Tag pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: data.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: data.accentColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  data.tag,
                  style: TextStyle(
                    color: data.accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 18),

              // Subtitle
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 15,
                  height: 1.65,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              // CTA button (halaman terakhir)
              if (data.isLast)
                Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _goToLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: data.accentColor,
                        foregroundColor: const Color(0xFF1B5E20),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Mulai Sekarang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    final pageData = _pages[_currentPage];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? pageData.accentColor
            : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _LandingPageData {
  final List<Color> backgroundGradient;
  final Color accentColor;
  final IconData iconData;
  final String tag;
  final String title;
  final String subtitle;
  final bool isLast;

  const _LandingPageData({
    required this.backgroundGradient,
    required this.accentColor,
    required this.iconData,
    required this.tag,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });
}