// lib/screens/petani/petani_beranda_screen.dart
// Dashboard beranda khusus role "petani"
// Menampilkan: sapaan, ringkasan lahan & panen, riwayat panen terbaru

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/panen_model.dart';
import '../../services/auth_service.dart';
import '../../services/petani_profile_service.dart';
import '../../widgets/app_top_bar.dart';

class PetaniBerandaScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  const PetaniBerandaScreen({super.key, this.onNavigateToTab});

  @override
  State<PetaniBerandaScreen> createState() => _PetaniBerandaScreenState();
}

class _PetaniBerandaScreenState extends State<PetaniBerandaScreen> {
  final PetaniProfileService _svc = PetaniProfileService();

  Map<String, dynamic> _ringkasan = {};
  List<PanenModel>     _panenTerbaru = [];
  String               _namaPetani = '';
  bool                 _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = await AuthService().getCachedUser();
      final results = await Future.wait([
        _svc.getRingkasan(),
        _svc.getPanen(perPage: 5),
      ]);

      if (mounted) {
        setState(() {
          _namaPetani = (results[0] as Map<String, dynamic>)['petani']
                  ?['nama'] as String? ??
              user?.name ??
              'Petani';
          _ringkasan     = results[0] as Map<String, dynamic>;
          _panenTerbaru  = results[1] as List<PanenModel>;
          _loading       = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Format helpers ─────────────────────────────────────────────────────
  String _fmtKg(dynamic v) {
    final val = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0;
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)} T';
    return '${val.toStringAsFixed(0)} kg';
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
      appBar: const AppTopBar(showAlert: false),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildRingkasan(),
                  const SizedBox(height: 28),
                  _buildAksesCepat(),
                  const SizedBox(height: 28),
                  _buildPanenTerbaru(),
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

  // ── Akses Cepat ────────────────────────────────────────────────────────
  Widget _buildAksesCepat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akses Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _menuTile(
          icon: Icons.agriculture_outlined,
          label: 'Riwayat Panen',
          sub: 'Lihat semua catatan panen saya',
          onTap: () => widget.onNavigateToTab?.call(1),
        ),
        _menuTile(
          icon: Icons.person_outline,
          label: 'Profil Saya',
          sub: 'Data diri & informasi lahan',
          onTap: () => widget.onNavigateToTab?.call(2),
        ),
      ],
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String label,
    required String sub,
    required VoidCallback onTap,
  }) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Riwayat Panen Terbaru ──────────────────────────────────────────────
  Widget _buildPanenTerbaru() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Panen Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (_panenTerbaru.isNotEmpty)
              GestureDetector(
                onTap: () => widget.onNavigateToTab?.call(1),
                child: Text(
                  'Lihat semua',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_panenTerbaru.isEmpty)
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
          )
        else
          ...(_panenTerbaru.map((p) => _panenTile(p))),
      ],
    );
  }

  Widget _panenTile(PanenModel p) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accentGreenLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.grass_outlined,
              color: AppColors.accentGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.lahan?.namaLahan ?? 'Lahan #${p.lahanId}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  p.tanggalPanen,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${p.jumlahGabah.toStringAsFixed(0)} kg',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.accentOrange,
                ),
              ),
              Text(
                'gabah',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
