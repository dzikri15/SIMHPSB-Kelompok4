// lib/screens/gudang_screen.dart
// Tampilan sesuai web SIMHPSB — 8 summary card + filter + mutasi list
// Terhubung ke Laravel via:
//   GET  /api/stok/summary   → ringkasan statistik
//   GET  /api/stok/transaksi → daftar mutasi (filterable)
//   POST /api/stok/catat     → catat transaksi baru

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/catat_transaksi_dialog.dart';
import '../services/transaksi_stok_service.dart';
import '../services/stok_service.dart';
import '../models/gudang_summary_model.dart';
import '../models/transaksi_stok_model.dart';

// ── Palette tambahan ──────────────────────────────────────────────────────
// Gunakan dari AppColors untuk consistency dengan theme

class GudangScreen extends StatefulWidget {
  const GudangScreen({super.key});

  @override
  State<GudangScreen> createState() => _GudangScreenState();
}

class _GudangScreenState extends State<GudangScreen> {
  final TransaksiStokService _transaksiService = TransaksiStokService();
  final StokService           _stokService     = StokService();

  // Refresh keys
  int _summaryKey    = 0;
  int _transaksiKey  = 0;

  // Filter transaksi
  final _searchCtrl = TextEditingController();
  String? _filterJenis;
  String? _filterKomoditas;


  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _summaryKey++;
      _transaksiKey++;
    });
  }

  void _applyFilter() => setState(() => _transaksiKey++);

  // ──────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppTopBar(),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Judul ──────────────────────────────────────────
                  Text('Stok Gudang',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 2),
                  Text(
                    'Transaksi masuk/keluar dan saldo stok real-time',
                    style: TextStyle(
                        fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),

                  // ── 8 Summary Cards ────────────────────────────────
                  _buildSummarySection(),
                  const SizedBox(height: 28),

                  // ── Header Mutasi + Tombol Catat ───────────────────
                  _buildMutasiHeader(),
                  const SizedBox(height: 14),

                  // ── Filter Bar ─────────────────────────────────────
                  _buildFilterBar(),
                  const SizedBox(height: 14),

                  // ── Tabel Transaksi ────────────────────────────────
                  _buildTransaksiSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ══════════════════════════════════════════════════════════════════════
  // 8 SUMMARY CARDS
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildSummarySection() {
    return FutureBuilder<GudangSummaryModel>(
      key: ValueKey('summary_$_summaryKey'),
      future: _stokService.getSummary(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return _errorCard('Gagal memuat ringkasan: ${snap.error}');
        }
        final s = snap.data;
        if (s == null) return const SizedBox.shrink();

        return Column(
          children: [
            // Row 1: 4 kartu besar dengan icon
            // FIX: Removed IntrinsicHeight + CrossAxisAlignment.stretch to prevent overflow
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _summaryCardLarge(
                    accentColor: AppColors.accentGreen,
                    icon: Icons.inventory_2_outlined,
                    iconBg: AppColors.primaryContainer,
                    iconColor: AppColors.accentGreen,
                    value: _fmtKg(s.saldoBeras),
                    label: 'Saldo Beras',
                    subtitle: '${(s.persenBeras * 100).toStringAsFixed(0)}% '
                        'kapasitas (max ${_fmtKg(s.kapasitasBeras)})',
                    progress: s.persenBeras.clamp(0, 1.0),
                    progressColor: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCardLarge(
                    accentColor: AppColors.accentOrange,
                    icon: Icons.grass_outlined,
                    iconBg: AppColors.accentOrangeLight,
                    iconColor: AppColors.accentOrange,
                    value: _fmtKg(s.saldoGabah),
                    label: 'Saldo Gabah',
                    subtitle: '${(s.persenGabah * 100).toStringAsFixed(0)}% '
                        'kapasitas (max ${_fmtKg(s.kapasitasGabah)})',
                    progress: s.persenGabah.clamp(0, 1.0),
                    progressColor: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // FIX: Removed IntrinsicHeight + CrossAxisAlignment.stretch to prevent overflow
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _summaryCardLarge(
                    accentColor: AppColors.accentBlue,
                    icon: Icons.south_rounded,
                    iconBg: AppColors.accentBlueLight,
                    iconColor: AppColors.accentBlue,
                    value: _fmtKg(s.masukBulanIni),
                    label: 'Masuk Bulan Ini',
                    badge: '↑ Gabah + Beras',
                    badgeColor: AppColors.accentBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCardLarge(
                    accentColor: AppColors.accentRed,
                    icon: Icons.north_rounded,
                    iconBg: AppColors.accentRedLight,
                    iconColor: AppColors.accentRed,
                    value: _fmtKg(s.keluarBulanIni),
                    label: 'Keluar Bulan Ini',
                    badge: '↓ Distribusi aktif',
                    badgeColor: AppColors.accentRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: 4 kartu kecil (per komoditas bulan ini)
            // FIX: Removed IntrinsicHeight + CrossAxisAlignment.stretch to prevent overflow
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _summaryCardSmall(
                    accentColor: AppColors.accentBlue,
                    icon: Icons.move_to_inbox_outlined,
                    iconBg: AppColors.accentBlueLight,
                    iconColor: AppColors.accentBlue,
                    value: _fmtKg(s.masukBerasBulanIni),
                    label: 'Masuk Beras\nBulan Ini',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCardSmall(
                    accentColor: AppColors.accentOrange,
                    icon: Icons.move_to_inbox_outlined,
                    iconBg: AppColors.accentOrangeLight,
                    iconColor: AppColors.accentOrange,
                    value: _fmtKg(s.masukGabahBulanIni),
                    label: 'Masuk Gabah\nBulan Ini',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // FIX: Removed IntrinsicHeight + CrossAxisAlignment.stretch to prevent overflow
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _summaryCardSmall(
                    accentColor: AppColors.accentRed,
                    icon: Icons.outbox_outlined,
                    iconBg: AppColors.accentRedLight,
                    iconColor: AppColors.accentRed,
                    value: _fmtKg(s.keluarBerasBulanIni),
                    label: 'Keluar Beras\nBulan Ini',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCardSmall(
                    accentColor: AppColors.accentRed,
                    icon: Icons.outbox_outlined,
                    iconBg: AppColors.accentRedLight,
                    iconColor: AppColors.accentRed,
                    value: _fmtKg(s.keluarGabahBulanIni),
                    label: 'Keluar Gabah\nBulan Ini',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ── Card Besar (dengan ikon + progress bar opsional) ──────────────────
  Widget _summaryCardLarge({
    required Color accentColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
    String? subtitle,
    String? badge,
    Color? badgeColor,
    double? progress,
    Color? progressColor,
  }) {
    return Container(
      clipBehavior: Clip.hardEdge,
      // FIX: Use symmetric padding with reduced vertical to avoid overflow
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border(top: BorderSide(color: accentColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // FIX: min so column doesn't overexpand
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8), // FIX: reduced from 12 → 8
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          if (progress != null) ...[
            const SizedBox(height: 6), // FIX: reduced from 8 → 6
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor ?? accentColor),
                minHeight: 4,
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
          if (badge != null) ...[
            const SizedBox(height: 6), // FIX: reduced from 8 → 6
            Text(badge,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? accentColor)),
          ],
        ],
      ),
    );
  }

  // ── Card Kecil (per komoditas bulan ini) ─────────────────────────────
  Widget _summaryCardSmall({
    required Color accentColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border(top: BorderSide(color: accentColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 1),
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // HEADER MUTASI
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildMutasiHeader() {
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mutasi Barang',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface)),
            Text('Riwayat transaksi masuk & keluar',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      ElevatedButton.icon(
        onPressed: _showCatatTransaksiDialog,
        icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
        label: const Text('Catat Transaksi',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════
  // FILTER BAR
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildFilterBar() {
    return Column(
      children: [
        // Search
        TextField(
          controller: _searchCtrl,
          style: const TextStyle(fontSize: 14),
          onSubmitted: (_) => _applyFilter(),
          decoration: InputDecoration(
            hintText: 'Cari tujuan, komoditas...',
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
            prefixIcon: Icon(Icons.search,
                color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () {
                      _searchCtrl.clear();
                      _applyFilter();
                    },
                  )
                : null,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.outlineVariant)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.outlineVariant)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5)),
          ),
        ),
        const SizedBox(height: 10),
        // Filter chips
        Row(children: [
          Expanded(
              child: _filterDropdown(
            value: _filterJenis,
            hint: 'Semua Jenis',
            items: const ['Masuk', 'Keluar'],
            onChanged: (v) {
              _filterJenis = v;
              _applyFilter();
            },
          )),
          const SizedBox(width: 10),
          Expanded(
              child: _filterDropdown(
            value: _filterKomoditas,
            hint: 'Semua Komoditas',
            items: const ['Gabah', 'Beras'],
            onChanged: (v) {
              _filterKomoditas = v;
              _applyFilter();
            },
          )),
          if (_filterJenis != null || _filterKomoditas != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                _filterJenis = null;
                _filterKomoditas = null;
                _applyFilter();
              },
              icon: Icon(Icons.filter_alt_off,
                  size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
              tooltip: 'Reset filter',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ]
        ]),
      ],
    );
  }

  Widget _filterDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint,
            style: TextStyle(
                fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        isExpanded: true,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(12),
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
        items: [
          DropdownMenuItem<String>(
              value: null,
              child: Text(hint,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant))),
          ...items.map((i) =>
              DropdownMenuItem<String>(value: i, child: Text(i))),
        ],
        onChanged: onChanged,
        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // DAFTAR TRANSAKSI
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildTransaksiSection() {
    return FutureBuilder<List<TransaksiStokModel>>(
      key: ValueKey('transaksi_$_transaksiKey'),
      future: _transaksiService.getAll(
        jenis:     _filterJenis?.toLowerCase(),
        komoditas: _filterKomoditas,
        q:         _searchCtrl.text,
      ),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return _errorCard('${snap.error}');
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return _emptyCard('Belum ada data transaksi.');
        }

        return Column(
          children: list
              .map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _transaksiTile(t),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _transaksiTile(TransaksiStokModel t) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final isMasuk = t.isMasuk;
    final jenisColor  = isMasuk ? AppColors.accentBlue : AppColors.accentRed;
    final jenisIconBg = isMasuk
        ? AppColors.accentBlueLight
        : AppColors.accentRedLight;
    final jenisIcon = isMasuk ? Icons.login_rounded : Icons.logout_rounded;
    final jenisLabel = isMasuk ? 'Masuk' : 'Keluar';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon jenis
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                    color: jenisIconBg,
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(jenisIcon, color: jenisColor, size: 24),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Komoditas
                              Text(t.komoditasDisplay,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).colorScheme.onSurface)),
                              const SizedBox(height: 2),
                              // Keterangan
                              Text(t.keteranganDisplay,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Jumlah
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(t.jumlahDisplay,
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: jenisColor)),
                            const SizedBox(height: 2),
                            // Jenis badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: jenisColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: jenisColor.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(jenisIcon,
                                      size: 10, color: jenisColor),
                                  const SizedBox(width: 4),
                                  Text(jenisLabel,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: jenisColor)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Bottom row: tanggal / saldo / dicatat oleh ─────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _infoChip(Icons.schedule_outlined,
                    t.tanggalLabel ?? '-'),
                const SizedBox(width: 8),
                _infoChip(
                    Icons.account_balance_wallet_outlined,
                    'Saldo: ${t.saldoDisplay}'),
                const Spacer(),
                _infoChip(Icons.person_outline,
                    t.dicatatOleh ?? 'Admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════
  String _fmtKg(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)} T';
    return '${v.toStringAsFixed(0)} kg';
  }

  Widget _errorCard(String msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(msg,
              style: const TextStyle(
                  color: AppColors.error, fontSize: 12)),
        ),
        TextButton(
            onPressed: _refresh,
            child: const Text('Retry',
                style: TextStyle(color: AppColors.primary))),
      ]),
    );
  }

  Widget _emptyCard(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 48, color: AppColors.outline.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(msg,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // DIALOG CATAT TRANSAKSI
  // ══════════════════════════════════════════════════════════════════════
  void _showCatatTransaksiDialog() {
    showDialog(
      context: context,
      builder: (_) => CatatTransaksiDialog(
        onSave: (data) => _saveCatatTransaksi(data),
      ),
    );
  }

  Future<void> _saveCatatTransaksi(Map<String, dynamic> data) async {
    try {
      await _transaksiService.create(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Transaksi berhasil dicatat'),
            ]),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}