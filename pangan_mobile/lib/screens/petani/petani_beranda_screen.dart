// lib/screens/petani/petani_beranda_screen.dart
// Dashboard beranda khusus role "petani"
// Menampilkan: sapaan, ringkasan lahan & panen, riwayat panen terbaru

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/panen_model.dart';
import '../../services/auth_service.dart';
import '../../services/petani_profile_service.dart';
import '../../widgets/app_top_bar.dart';
import '../login_screen.dart';

class PetaniBerandaScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const PetaniBerandaScreen({
    super.key,
    this.onProfileTap,
  });

  @override
  State<PetaniBerandaScreen> createState() => _PetaniBerandaScreenState();
}

class _PetaniBerandaScreenState extends State<PetaniBerandaScreen> {
  final PetaniProfileService _svc = PetaniProfileService();

  Map<String, dynamic> _ringkasan = {};
  List<PanenModel>     _allPanen = [];
  String               _namaPetani = '';
  bool                 _loading = true;
  
  // Pagination
  static const int _pageSize = 5;
  int _currentPage = 1;

  final ScrollController _rekapScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _rekapScrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = await AuthService().getCachedUser();
      final results = await Future.wait([
        _svc.getRingkasan(),
        _svc.getPanen(perPage: 100),
      ]);

      if (mounted) {
        setState(() {
          _namaPetani = (results[0] as Map<String, dynamic>)['petani']
                  ?['nama'] as String? ??
              user?.name ??
              'Petani';
          _ringkasan     = results[0] as Map<String, dynamic>;
          _allPanen      = results[1] as List<PanenModel>;
          _currentPage   = 1;
          _loading       = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await AuthService().logout();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    });
  }

  // ── Format helpers ─────────────────────────────────────────────────────
  String _fmtKg(dynamic v) {
    final val = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0;
    return '${val.toStringAsFixed(0)} kg';
  }

  String _fmtRupiah(double v) {
    if (v >= 1000000) return 'Rp${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) {
      final thousands = v / 1000;
      return thousands % 1 == 0
          ? 'Rp${thousands.toStringAsFixed(0)}rb'
          : 'Rp${thousands.toStringAsFixed(1)}rb';
    }
    return 'Rp${v.toStringAsFixed(0)}';
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(
        showAlert: false,
        showProfile: false, // Sembunyikan profile icon dari kanan atas
        onProfileTap: widget.onProfileTap,
        showMenu: true,     // Tampilkan menu titik 3
        showLogout: true,   // Tampilkan menu log out di dalam titik 3
        onLogoutTap: _logout,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildRingkasan(),
                  const SizedBox(height: 28),
                  _buildRekapHarian(),
                  const SizedBox(height: 28),
                  _buildPanenRiwayat(),
                ],
              ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greeting()},',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _namaPetani,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco, size: 13, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                'Petani',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Ringkasan ──────────────────────────────────────────────────────────
  Widget _buildRingkasan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _kartu(
              icon: Icons.terrain_outlined,
              label: 'Total Lahan',
              value: '${_ringkasan['total_lahan'] ?? 0}',
              satuan: 'petak',
              warna: AppColors.primary,
              bg: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _kartu(
              icon: Icons.agriculture_outlined,
              label: 'Total Panen',
              value: '${_ringkasan['total_panen'] ?? 0}',
              satuan: 'catatan',
              warna: AppColors.accentBlue,
              bg: AppColors.accentBlueLight,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _kartu(
              icon: Icons.grass_outlined,
              label: 'Total Gabah',
              value: _fmtKg(_ringkasan['total_gabah_kg'] ?? 0),
              satuan: 'keseluruhan',
              warna: AppColors.accentOrange,
              bg: AppColors.accentOrangeLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _kartu(
              icon: Icons.inventory_2_outlined,
              label: 'Total Beras',
              value: _fmtKg(_ringkasan['total_beras_kg'] ?? 0),
              satuan: 'hasil konversi',
              warna: AppColors.primary,
              bg: AppColors.primaryContainer,
            ),
          ),
        ]),
      ],
    );
  }

  Widget _kartu({
    required IconData icon,
    required String label,
    required String value,
    required String satuan,
    required Color warna,
    required Color bg,
  }) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border(top: BorderSide(color: warna, width: 3)),
        boxShadow: [
          BoxShadow(
            color: warna.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: warna, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            satuan,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ── Panen Riwayat dengan Pagination ────────────────────────────────────
  Widget _buildPanenRiwayat() {
    if (_allPanen.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Panen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.agriculture_outlined,
                      size: 40, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada catatan panen.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final totalPages = (_allPanen.length / _pageSize).ceil().clamp(1, 9999);
    final safePage = _currentPage.clamp(1, totalPages);
    final startIdx = (safePage - 1) * _pageSize;
    final endIdx = (startIdx + _pageSize).clamp(0, _allPanen.length);
    final pagedList = _allPanen.sublist(startIdx, endIdx);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Panen',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...pagedList.map((p) => _buildPanenCard(p)),
        if (totalPages > 1) ...[
          const SizedBox(height: 16),
          _buildPaginationBar(safePage, totalPages, _allPanen.length),
        ],
      ],
    );
  }

  Widget _buildPanenCard(PanenModel p) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final nilaiPanen = p.nilaiPanen;
    final hasNilai   = nilaiPanen > 0;
    final headerTextColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkSecondary
        : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header kartu
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.grass_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gabah',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: headerTextColor,
                        ),
                      ),
                      Text(
                        p.tanggalPanen,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (p.musimLabel != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      p.musimLabel!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onTertiaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statItem(
                  label: 'Gabah',
                  value: _fmtKg(p.jumlahGabah),
                  icon: Icons.grain,
                  color: AppColors.accentOrange,
                ),
                if (hasNilai) ...[
                  _dividerV(),
                  _statItem(
                    label: 'Pendapatan',
                    value: _fmtRupiah(nilaiPanen),
                    icon: Icons.payments_outlined,
                    color: AppColors.accentBlue,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 110,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerV() {
    return Container(
      height: 36,
      width: 1,
      color: AppColors.outlineVariant,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildPaginationBar(int currentPage, int totalPages, int totalItems) {
    final startItem = ((currentPage - 1) * _pageSize) + 1;
    final endItem = (currentPage * _pageSize).clamp(0, totalItems);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$startItem–$endItem dari $totalItems',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              _pageBtn(
                icon: Icons.chevron_left_rounded,
                enabled: currentPage > 1,
                onTap: () => setState(() => _currentPage = currentPage - 1),
              ),
              const SizedBox(width: 4),
              ..._buildPageNumbers(currentPage, totalPages),
              const SizedBox(width: 4),
              _pageBtn(
                icon: Icons.chevron_right_rounded,
                enabled: currentPage < totalPages,
                onTap: () => setState(() => _currentPage = currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int current, int total) {
    final pages = <int>[];
    if (total <= 5) {
      pages.addAll(List.generate(total, (i) => i + 1));
    } else {
      pages.add(1);
      if (current > 3) pages.add(-1);
      for (int i = (current - 1).clamp(2, total - 1);
          i <= (current + 1).clamp(2, total - 1);
          i++) {
        pages.add(i);
      }
      if (current < total - 2) pages.add(-1);
      pages.add(total);
    }
    return pages.map((p) {
      if (p == -1) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        );
      }
      final isActive = p == current;
      return GestureDetector(
        onTap: () => setState(() => _currentPage = p),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Center(
            child: Text(
              '$p',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _pageBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? Theme.of(context).colorScheme.outlineVariant
                : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ── Rekap Harian ───────────────────────────────────────────────────────
  Widget _buildRekapHarian() {
    if (_allPanen.isEmpty) return const SizedBox.shrink();

    // Mengelompokkan panen berdasarkan tanggal
    final Map<String, _RekapDay> maps = {};
    for (final p in _allPanen) {
      final key = p.tanggalPanen;
      final item = maps.putIfAbsent(key, () => _RekapDay(key));
      item.totalGabah += p.jumlahGabah;
      item.totalPendapatan += p.nilaiPanen;
      item.entriCount += 1;
    }

    final list = maps.values.toList()
      ..sort((a, b) => b.dateRaw.compareTo(a.dateRaw));

    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REKAP HARIAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Gabah per Tanggal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          
          // Container dengan tinggi tetap dan Scrollbar agar bisa di-scroll tanpa paging
          SizedBox(
            height: 250,
            child: Scrollbar(
              controller: _rekapScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              thickness: 5,
              radius: const Radius.circular(8),
              child: ListView.separated(
                controller: _rekapScrollController,
                padding: const EdgeInsets.only(right: 12), // Jarak agar tidak bertabrakan dengan Scrollbar
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Divider(color: cs.outlineVariant.withValues(alpha: 0.3)),
                ),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fmtTanggalRekap(item.dateRaw),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.entriCount} entri panen',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _fmtKgFull(item.totalGabah),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            if (item.totalPendapatan > 0) ...[
                              const SizedBox(height: 2),
                              Text(
                                _fmtRupiahFull(item.totalPendapatan),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper formatters tambahan ─────────────────────────────────────────
  String _fmtTanggalRekap(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const bulanS = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day.toString().padLeft(2, '0')} ${bulanS[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String _fmtKgFull(double v) {
    final formatted = v.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted kg';
  }

  String _fmtRupiahFull(double v) {
    final formatted = v.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}

// Class penampung rekap harian
class _RekapDay {
  final String dateRaw;
  double totalGabah = 0;
  double totalPendapatan = 0;
  int entriCount = 0;

  _RekapDay(this.dateRaw);
}