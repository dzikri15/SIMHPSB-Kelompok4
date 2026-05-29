// lib/screens/beranda_screen.dart
// Beranda SIMHPSB — data real-time dari API

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/transaksi_stok_model.dart';
import '../services/api_service.dart';
import '../services/transaksi_stok_service.dart';
import '../widgets/app_top_bar.dart';

class BerandaScreen extends StatefulWidget {
  final Function(int)? onNavigateToScreen;
  const BerandaScreen({super.key, this.onNavigateToScreen});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final ApiService            _api      = ApiService();
  final TransaksiStokService  _transaksi = TransaksiStokService();

  Map<String, dynamic>    _ringkasan = {};
  List<TransaksiStokModel> _aktivitas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // User dari cache

      // Ringkasan: petani, panen bulan ini, stok
      final results = await Future.wait([
        _api.get('petani?per_page=1'),
        _api.get('panen?per_page=1'),
        _api.get('stok/summary'),
      ]);

      final petaniData = results[0] as Map<String, dynamic>?;
      final panenData  = results[1] as Map<String, dynamic>?;
      final stokData   = results[2] as Map<String, dynamic>?;

      // Aktivitas terbaru
      final akt = await _transaksi.getAll();

      if (mounted) {
        setState(() {
          _ringkasan = {
            'total_petani': petaniData?['total'] ?? petaniData?['meta']?['total'] ?? 0,
            'total_panen':  panenData?['total']  ?? panenData?['meta']?['total']  ?? 0,
            'saldo_beras':  stokData?['saldo_beras']  ?? 0,
            'saldo_gabah':  stokData?['saldo_gabah']  ?? 0,
          };
          _aktivitas = akt.take(5).toList();
          _loading = false;
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
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildRingkasan(),
                  const SizedBox(height: 28),
                  _buildAksesCepat(),
                  const SizedBox(height: 28),
                  _buildAktivitas(),
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
        Text('${_greeting()},',
            style: const TextStyle(
                fontSize: 13, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        const Text('Petugas',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.5)),
      ],
    );
  }

  // ── 4 Kartu Ringkasan ──────────────────────────────────────────────────
  Widget _buildRingkasan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ringkasan',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _kartu(
              icon: Icons.people_alt_outlined,
              label: 'Total Petani',
              value: '${_ringkasan['total_petani'] ?? 0}',
              satuan: 'orang',
              warna: AppColors.primary,
              bg: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _kartu(
              icon: Icons.agriculture_outlined,
              label: 'Data Panen',
              value: '${_ringkasan['total_panen'] ?? 0}',
              satuan: 'catatan',
              warna: const Color(0xFF1565C0),
              bg: const Color(0xFFE3F2FD),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _kartu(
              icon: Icons.inventory_2_outlined,
              label: 'Saldo Beras',
              value: _fmtKg(_ringkasan['saldo_beras'] ?? 0),
              satuan: 'terkini',
              warna: const Color(0xFF2E7D32),
              bg: const Color(0xFFE8F5E9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _kartu(
              icon: Icons.grass_outlined,
              label: 'Saldo Gabah',
              value: _fmtKg(_ringkasan['saldo_gabah'] ?? 0),
              satuan: 'terkini',
              warna: const Color(0xFFE65100),
              bg: const Color(0xFFFFF3E0),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant)),
          Text(satuan,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  // ── Akses Cepat ────────────────────────────────────────────────────────
  Widget _buildAksesCepat() {
    final menus = [
      const _Menu(Icons.people_alt_outlined, 'Data Petani',
          'Registrasi & profil petani', 1),
      const _Menu(Icons.agriculture_outlined, 'Input Panen',
          'Catat hasil panen baru', 2),
      const _Menu(Icons.warehouse_outlined,  'Stok Gudang',
          'Mutasi & saldo gudang',   3),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Akses Cepat',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface)),
        const SizedBox(height: 12),
        ...menus.map((m) => _menuTile(m)),
      ],
    );
  }

  Widget _menuTile(_Menu m) {
    return GestureDetector(
      onTap: () => widget.onNavigateToScreen?.call(m.index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
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
              child: Icon(m.icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.onSurface)),
                  Text(m.sub,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Aktivitas Terakhir ─────────────────────────────────────────────────
  Widget _buildAktivitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aktivitas Terakhir',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface)),
        const SizedBox(height: 12),
        if (_aktivitas.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: const Center(
              child: Text('Belum ada transaksi.',
                  style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
          )
        else
          ...(_aktivitas.map((t) => _aktivitasTile(t))),
      ],
    );
  }

  Widget _aktivitasTile(TransaksiStokModel t) {
    final isMasuk = t.isMasuk;
    final warna   = isMasuk ? const Color(0xFF1565C0) : AppColors.error;
    final bg      = isMasuk ? const Color(0xFFE3F2FD) : const Color(0xFFFFEBEE);
    final icon    = isMasuk ? Icons.login_rounded : Icons.logout_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: warna, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.komoditasDisplay,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.onSurface)),
                Text(t.tanggalLabel ?? '-',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Text(t.jumlahDisplay,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 14, color: warna)),
        ],
      ),
    );
  }
}

class _Menu {
  final IconData icon;
  final String label;
  final String sub;
  final int index;
  const _Menu(this.icon, this.label, this.sub, this.index);
}
