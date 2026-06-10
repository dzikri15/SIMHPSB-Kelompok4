// lib/screens/petani/petani_panen_screen.dart
// Riwayat panen milik petani yang sedang login

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/panen_model.dart';
import '../../services/petani_profile_service.dart';
import '../../widgets/app_top_bar.dart';

class PetaniPanenScreen extends StatefulWidget {
  const PetaniPanenScreen({super.key});

  @override
  State<PetaniPanenScreen> createState() => _PetaniPanenScreenState();
}

class _PetaniPanenScreenState extends State<PetaniPanenScreen> {
  final PetaniProfileService _svc = PetaniProfileService();

  List<PanenModel> _panens = [];
  bool             _loading = true;
  String?          _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _svc.getPanen(perPage: 50);
      if (mounted) setState(() { _panens = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _fmtKg(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)} T';
    return '${v.toStringAsFixed(0)} kg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppTopBar(showAlert: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page Header ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riwayat Panen',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Semua catatan panen saya',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).colorScheme.outline),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : _panens.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: AppColors.primary,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                              itemCount: _panens.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) => _buildCard(_panens[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(PanenModel p) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final nilaiPanen = p.nilaiPanen;
    final hasNilai   = nilaiPanen > 0;

    return Container(
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
                        p.lahan?.namaLahan ?? 'Lahan #${p.lahanId}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
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
          // Body kartu — stats
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                _statItem(
                  label: 'Gabah',
                  value: _fmtKg(p.jumlahGabah),
                  icon: Icons.grain,
                  color: AppColors.accentOrange,
                ),
                _dividerV(),
                _statItem(
                  label: 'Beras',
                  value: _fmtKg(p.konversiBeras ?? 0),
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.accentGreen,
                ),
                if (hasNilai) ...[
                  _dividerV(),
                  _statItem(
                    label: 'Nilai',
                    value: _fmtRupiah(nilaiPanen),
                    icon: Icons.payments_outlined,
                    color: AppColors.accentBlue,
                  ),
                ],
              ],
            ),
          ),
          // Catatan (opsional)
          if (p.catatan != null && p.catatan!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                '📝 ${p.catatan}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
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
    return Expanded(
      child: Column(
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  String _fmtRupiah(double v) {
    if (v >= 1000000) return 'Rp${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return 'Rp${(v / 1000).toStringAsFixed(0)}rb';
    return 'Rp${v.toStringAsFixed(0)}';
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.agriculture_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada catatan panen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Data panen akan muncul di sini\nsetelah dicatat oleh petugas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(_error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
