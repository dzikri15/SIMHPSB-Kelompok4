// lib/screens/gudang_screen.dart
// Tampilan sesuai web SIMHP — 8 summary card + filter + mutasi list
// Terhubung ke Laravel via:
//   GET  /api/stok/summary   → ringkasan statistik
//   GET  /api/stok/transaksi → daftar mutasi (filterable)
//   POST /api/stok/catat     → catat transaksi baru

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/constants.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/catat_transaksi_dialog.dart';
import '../services/transaksi_stok_service.dart';
import '../services/stok_service.dart';
import '../models/gudang_summary_model.dart';
import '../models/transaksi_stok_model.dart';

// ── Palette tambahan ──────────────────────────────────────────────────────
// Gunakan dari AppColors untuk consistency dengan theme

class GudangScreen extends StatefulWidget {
  final VoidCallback? onLogoutTap;
  const GudangScreen({super.key, this.onLogoutTap});

  @override
  State<GudangScreen> createState() => _GudangScreenState();
}

class _GudangScreenState extends State<GudangScreen> {
  final TransaksiStokService _transaksiService = TransaksiStokService();
  final StokService _stokService = StokService();

  // Refresh keys
  int _summaryKey = 0;
  int _transaksiKey = 0;

  // Filter transaksi
  final _searchCtrl = TextEditingController();
  String? _filterJenis;
  String? _filterKomoditas;
  DateTime? _filterTanggalMulai;
  DateTime? _filterTanggalAkhir;

  // Paging transaksi
  static const int _pageSize = 10;
  int _currentPage = 1;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _summaryKey++;
      _transaksiKey++;
      _currentPage = 1;
    });
  }

  void _applyFilter() => setState(() {
        _transaksiKey++;
        _currentPage = 1;
      });

  // ──────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(
        showMenu: widget.onLogoutTap != null,
        showLogout: widget.onLogoutTap != null,
        onLogoutTap: widget.onLogoutTap,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Judul + Summary Cards (padding normal) ────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
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
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  _buildSummarySection(),
                  const SizedBox(height: 28),
                ]),
              ),
            ),

            // ── Header Mutasi + Filter (padding normal) ───────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMutasiHeader(),
                  const SizedBox(height: 14),
                  _buildFilterBar(),
                  const SizedBox(height: 14),
                ]),
              ),
            ),

            // ── Tabel Transaksi — full width, padding minimal ─────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
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
            width: 40,
            height: 40,
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
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                valueColor:
                    AlwaysStoppedAnimation<Color>(progressColor ?? accentColor),
                minHeight: 4,
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
            width: 36,
            height: 36,
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
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      ElevatedButton.icon(
        onPressed: _showCatatTransaksiDialog,
        icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
        label: const Text('Catat Transaksi',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13),
            prefixIcon: Icon(Icons.search,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear,
                        size: 18,
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
                borderSide: const BorderSide(color: AppColors.outlineVariant)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.outlineVariant)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5)),
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
          if (_filterJenis != null ||
              _filterKomoditas != null ||
              _filterTanggalMulai != null ||
              _filterTanggalAkhir != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                _filterJenis = null;
                _filterKomoditas = null;
                _filterTanggalMulai = null;
                _filterTanggalAkhir = null;
                _applyFilter();
              },
              icon: Icon(Icons.filter_alt_off,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              tooltip: 'Reset filter',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ]
        ]),
        const SizedBox(height: 10),
        // Filter Tanggal
        _buildDateRangeFilter(),
      ],
    );
  }

  // ── Date Range Filter ─────────────────────────────────────────────────
  Widget _buildDateRangeFilter() {
    final bool hasDate =
        _filterTanggalMulai != null || _filterTanggalAkhir != null;
    return Row(
      children: [
        Expanded(
          child: _buildDatePickerButton(
            label: _filterTanggalMulai != null
                ? _fmtDate(_filterTanggalMulai!)
                : 'Dari Tanggal',
            icon: Icons.calendar_today_outlined,
            isActive: _filterTanggalMulai != null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _filterTanggalMulai ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: _filterTanggalAkhir ?? DateTime.now(),
                builder: (ctx, child) => _datePickerTheme(ctx, child),
              );
              if (picked != null) {
                setState(() => _filterTanggalMulai = picked);
                _applyFilter();
              }
            },
            onClear: _filterTanggalMulai != null
                ? () {
                    setState(() => _filterTanggalMulai = null);
                    _applyFilter();
                  }
                : null,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('–',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ),
        Expanded(
          child: _buildDatePickerButton(
            label: _filterTanggalAkhir != null
                ? _fmtDate(_filterTanggalAkhir!)
                : 'Sampai Tanggal',
            icon: Icons.calendar_today_outlined,
            isActive: _filterTanggalAkhir != null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _filterTanggalAkhir ??
                    (_filterTanggalMulai != null
                        ? _filterTanggalMulai!
                        : DateTime.now()),
                firstDate: _filterTanggalMulai ?? DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                builder: (ctx, child) => _datePickerTheme(ctx, child),
              );
              if (picked != null) {
                setState(() => _filterTanggalAkhir = picked);
                _applyFilter();
              }
            },
            onClear: _filterTanggalAkhir != null
                ? () {
                    setState(() => _filterTanggalAkhir = null);
                    _applyFilter();
                  }
                : null,
          ),
        ),
        if (hasDate) ...[
          const SizedBox(width: 6),
          Tooltip(
            message: 'Reset tanggal',
            child: InkWell(
              onTap: () {
                setState(() {
                  _filterTanggalMulai = null;
                  _filterTanggalAkhir = null;
                });
                _applyFilter();
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentRedLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.clear,
                    size: 18, color: AppColors.accentRed),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDatePickerButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final color = isActive
        ? AppColors.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : Theme.of(context).colorScheme.outline,
            width: isActive ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 14, color: color),
              ),
          ],
        ),
      ),
    );
  }

  Widget _datePickerTheme(BuildContext ctx, Widget? child) {
    return Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: Theme.of(ctx).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(ctx).colorScheme.surface,
            ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _filterDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border:
            Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        isExpanded: true,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(12),
        style: TextStyle(
            fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
        items: [
          DropdownMenuItem<String>(
              value: null,
              child: Text(hint,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant))),
          ...items
              .map((i) => DropdownMenuItem<String>(value: i, child: Text(i))),
        ],
        onChanged: onChanged,
        dropdownColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // TRANSAKSI SECTION — responsive: tabel di desktop, card list di mobile
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildTransaksiSection() {
    return FutureBuilder<List<TransaksiStokModel>>(
      key: ValueKey('transaksi_$_transaksiKey'),
      future: _transaksiService.getAll(
        jenis: _filterJenis?.toLowerCase(),
        komoditas: _filterKomoditas,
        q: _searchCtrl.text,
        tanggalMulai: _filterTanggalMulai != null
            ? '${_filterTanggalMulai!.year.toString().padLeft(4, '0')}-'
                '${_filterTanggalMulai!.month.toString().padLeft(2, '0')}-'
                '${_filterTanggalMulai!.day.toString().padLeft(2, '0')}'
            : null,
        tanggalAkhir: _filterTanggalAkhir != null
            ? '${_filterTanggalAkhir!.year.toString().padLeft(4, '0')}-'
                '${_filterTanggalAkhir!.month.toString().padLeft(2, '0')}-'
                '${_filterTanggalAkhir!.day.toString().padLeft(2, '0')}'
            : null,
      ),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) return _errorCard('${snap.error}');
        final list = snap.data ?? [];
        if (list.isEmpty) return _emptyCard('Belum ada data transaksi.');

        // ── Paging ────────────────────────────────────────────────
        final totalPages = (list.length / _pageSize).ceil().clamp(1, 9999);
        final safePage = _currentPage.clamp(1, totalPages);
        final startIdx = (safePage - 1) * _pageSize;
        final endIdx = (startIdx + _pageSize).clamp(0, list.length);
        final pagedList = list.sublist(startIdx, endIdx);

        return Column(
          children: [
            LayoutBuilder(builder: (ctx, constraints) {
              if (constraints.maxWidth >= 800) {
                return _buildDesktopTable(pagedList, constraints.maxWidth);
              }
              return _buildMobileList(pagedList);
            }),
            if (totalPages > 1)
              _buildPaginationBar(safePage, totalPages, list.length),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // PAGINATION BAR
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildPaginationBar(int currentPage, int totalPages, int totalItems) {
    final startItem = ((currentPage - 1) * _pageSize) + 1;
    final endItem = (currentPage * _pageSize).clamp(0, totalItems);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
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
              _pageTextBtn(
                label: 'First',
                enabled: currentPage > 1,
                onTap: () => setState(() => _currentPage = 1),
              ),
              const SizedBox(width: 4),
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
              const SizedBox(width: 4),
              _pageTextBtn(
                label: 'Last',
                enabled: currentPage < totalPages,
                onTap: () => setState(() => _currentPage = totalPages),
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
          child: Text('...',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
            color: isActive
                ? AppColors.primary
                : Theme.of(context).colorScheme.surface,
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
                color: isActive
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? Theme.of(context).colorScheme.outlineVariant
                : Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.4),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _pageTextBtn({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? Theme.of(context).colorScheme.outlineVariant
                : Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.4),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: enabled
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  // ── DESKTOP: Tabel full width ────────────────────────────────────────
  Widget _buildDesktopTable(
      List<TransaksiStokModel> list, double availableWidth) {
    const borderWidth = 2.0;
    final usable = availableWidth - borderWidth;

    // Lebar fixed per kolom, kolom Tujuan/Sumber menyerap sisa
    const fixedWidths = [
      48.0,
      130.0,
      72.0,
      80.0,
      90.0,
      72.0,
      72.0,
      52.0,
      120.0,
      52.0
    ];
    final fixedTotal = fixedWidths.fold(0.0, (a, b) => a + b);
    final tujuanW = (usable - fixedTotal).clamp(120.0, 300.0);

    final colWidths = [
      fixedWidths[0], // No
      fixedWidths[1], // Tanggal
      fixedWidths[2], // Jenis
      fixedWidths[3], // Komoditas
      fixedWidths[4], // Jumlah (kg)
      tujuanW, // Tujuan/Sumber — fleksibel
      fixedWidths[5], // Catatan
      fixedWidths[6], // Status
      fixedWidths[7], // Bukti
      fixedWidths[8], // Dicatat Oleh
      fixedWidths[9], // Aksi
    ];
    final headers = [
      'No',
      'Tanggal',
      'Jenis',
      'Komoditas',
      'Jumlah (kg)',
      'Tujuan/Sumber',
      'Catatan',
      'Status',
      'Bukti',
      'Dicatat Oleh',
      'Aksi'
    ];
    final numericCols = {4}; // Jumlah (kg)

    final tableW = colWidths.fold(0.0, (a, b) => a + b);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: availableWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.4),
          ),
        ),
        child: SizedBox(
          width: tableW,
          child: Column(
            children: [
              // Header
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Row(
                  children: List.generate(
                      headers.length,
                      (i) => SizedBox(
                            width: colWidths[i],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              child: Text(
                                headers[i],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 11),
                                textAlign: numericCols.contains(i)
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                          )),
                ),
              ),
              const Divider(height: 1, thickness: 1),
              // Rows
              ...List.generate(list.length, (idx) {
                final t = list[idx];
                final jenisColor = t.isMasuk ? AppColors.accentBlue : AppColors.accentRed;
                return GestureDetector(
                  onTap: () => _showTransaksiDetail(t),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: !t.isAktif
                        ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                        : idx % 2 == 0
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // No
                            SizedBox(width: colWidths[0], child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                              child: Text('${idx+1}', style: const TextStyle(fontSize: 11)),
                            )),
                            // Tanggal
                            SizedBox(width: colWidths[1], child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                              child: Text(t.tanggalLabel ?? '-', style: const TextStyle(fontSize: 11)),
                            )),
                            // Jenis badge
                            SizedBox(width: colWidths[2], child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                              child: _jenisBadge(t, jenisColor),
                            )),
                            // Komoditas
                            SizedBox(width: colWidths[3], child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                              child: Text(t.komoditasDisplay, style: const TextStyle(fontSize: 11)),
                            )),
                            // Jumlah
                            SizedBox(width: colWidths[4], child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                              child: Text(t.jumlahDisplay,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.right),
                            )),
                            // Tujuan/Sumber
                            SizedBox(width: colWidths[5], child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                              child: Text(
                                t.tujuanDistribusiNama ?? t.keteranganDisplay,
                                style: const TextStyle(fontSize: 11),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            )),
                            // Catatan
                            SizedBox(width: colWidths[6], child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                              child: Text(t.catatan ?? '-',
                                style: const TextStyle(fontSize: 10),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            )),
                            // Status
                            SizedBox(width: colWidths[7], child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                              child: _statusBadge(t),
                            )),
                            // Bukti
                            SizedBox(width: colWidths[8], child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                              child: t.fotoBukti != null && t.fotoBukti!.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () => _showFotoPreview(t.fotoBukti!),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.image, size: 18, color: AppColors.primary),
                                      ),
                                    )
                                  : const Text('-', style: TextStyle(fontSize: 11)),
                            )),
                            // Dicatat Oleh
                            SizedBox(width: colWidths[9], child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                              child: Text(t.dicatatOleh ?? 'Admin',
                                style: const TextStyle(fontSize: 11),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            )),
                            // Aksi
                            SizedBox(width: colWidths[10], child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _aksiButton(t),
                            )),
                          ],
                        ),
                        if (idx < list.length - 1)
                          Divider(height: 1, thickness: 0.5,
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── MOBILE: Card list yang menampilkan semua field ──────────────────
  Widget _buildMobileList(List<TransaksiStokModel> list) {
    return Column(
      children: List.generate(list.length, (idx) {
        final t = list[idx];
        final jenisColor =
            t.isMasuk ? AppColors.accentBlue : AppColors.accentRed;
        return Opacity(
          opacity: t.isAktif ? 1.0 : 0.6,
          child: GestureDetector(
            onTap: () => _showTransaksiDetail(t),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
                    blurRadius: 4, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                // ── Header baris: nomor + jenis badge + jumlah ──────
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: jenisColor.withValues(alpha: 0.06),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(children: [
                    Text('#${idx + 1}',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
                    const SizedBox(width: 8),
                    _jenisBadge(t, jenisColor),
                    const Spacer(),
                    Text(t.jumlahDisplay,
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900,
                        color: jenisColor,
                      )),
                  ]),
                ),
                // ── Body: semua field dalam grid 2 kolom ────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                  child: Column(
                    children: [
                      _mobileRow('Tanggal',      t.tanggalLabel ?? '-'),
                      _mobileRow('Komoditas',    t.komoditasDisplay),
                      _mobileRow('Tujuan/Sumber',
                        t.tujuanDistribusiNama ?? t.keteranganDisplay),
                      if ((t.catatan ?? '').isNotEmpty)
                        _mobileRow('Catatan', t.catatan!),
                      _mobileRow('Dicatat Oleh', t.dicatatOleh ?? 'Admin'),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .shadow
                          .withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ── Header baris: nomor + jenis badge + jumlah ──────
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: jenisColor.withValues(alpha: 0.06),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                      ),
                      child: Row(children: [
                        Text('#${idx + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            )),
                        const SizedBox(width: 8),
                        _jenisBadge(t, jenisColor),
                        const Spacer(),
                        Text(t.jumlahDisplay,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: jenisColor,
                            )),
                      ]),
                    ),
                    // ── Body: semua field dalam grid 2 kolom ────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                      child: Column(
                        children: [
                          _mobileRow('Tanggal', t.tanggalLabel ?? '-'),
                          _mobileRow('Komoditas', t.komoditasDisplay),
                          _mobileRow('Tujuan/Sumber',
                              t.tujuanDistribusiNama ?? t.keteranganDisplay),
                          if ((t.catatan ?? '').isNotEmpty)
                            _mobileRow('Catatan', t.catatan!),
                          _mobileRow('Dicatat Oleh', t.dicatatOleh ?? 'Admin'),
                        ],
                      ),
                    ),
                    // ── Footer: status + bukti + aksi ───────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                      child: Row(children: [
                        _statusBadge(t),
                        const SizedBox(width: 8),
                        if (t.fotoBukti != null && t.fotoBukti!.isNotEmpty)
                          GestureDetector(
                            onTap: () => _showFotoPreview(t.fotoBukti!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.image,
                                        size: 18, color: AppColors.primary),
                                    SizedBox(width: 6),
                                    Text('Bukti',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700)),
                                  ]),
                            ),
                          ),
                        const Spacer(),
                        _aksiButton(t),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      }),
    );
  }

  // ── Helper: satu baris field di mobile card ─────────────────────────
  Widget _mobileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
          ),
          const Text(': ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransaksiDetail(TransaksiStokModel t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurfaceVariant
                        .withAlpha(80),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Text('Detail Transaksi',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(ctx).colorScheme.onSurface)),
              const SizedBox(height: 12),
              _detailField('ID', '${t.id}'),
              _detailField('Tanggal', t.tanggalLabel ?? '-'),
              _detailField('Jenis', t.isMasuk ? 'Masuk' : 'Keluar'),
              _detailField('Komoditas', t.komoditasDisplay),
              _detailField('Jumlah', t.jumlahDisplay),
              _detailField('Tujuan/Sumber',
                  t.tujuanDistribusiNama ?? t.keteranganDisplay),
              _detailField('Dicatat Oleh', t.dicatatOleh ?? 'Admin'),
              _detailField('Status', t.isAktif ? 'Aktif' : 'Dibatalkan'),
              if ((t.catatan ?? '').isNotEmpty)
                _detailField('Catatan', t.catatan!),
              if (t.fotoBukti != null && t.fotoBukti!.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showFotoPreview(t.fotoBukti!);
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Lihat Bukti Foto'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _detailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }

  // ── Shared widgets ──────────────────────────────────────────────────
  Widget _jenisBadge(TransaksiStokModel t, Color jenisColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: jenisColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: jenisColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        t.isMasuk ? 'Masuk' : 'Keluar',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: jenisColor),
      ),
    );
  }

  Widget _statusBadge(TransaksiStokModel t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (t.isAktif ? Colors.green : Colors.grey).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        t.isAktif ? 'Aktif' : 'Dibatalkan',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: t.isAktif ? Colors.green[700] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _aksiButton(TransaksiStokModel t) {
    if (t.isAktif) {
      return Tooltip(
        message: 'Batalkan transaksi',
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: const Icon(Icons.cancel_outlined,
              size: 20, color: AppColors.accentRed),
          onPressed: () => _toggleStatus(t),
        ),
      );
    }
    return Tooltip(
      message: 'Aktifkan kembali',
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        icon: const Icon(Icons.replay, size: 20, color: AppColors.primary),
        onPressed: () => _toggleStatus(t),
      ),
    );
  }

  void _showTransaksiDetail(TransaksiStokModel t) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.92,
            maxHeight: MediaQuery.of(context).size.height * 0.86,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Detail Transaksi Stok',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // ── Scrollable body ────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('Jenis', t.isMasuk ? 'Masuk' : 'Keluar'),
                      _detailRow('Komoditas', t.komoditasDisplay),
                      _detailRow('Jumlah', t.jumlahDisplay),
                      _detailRow('Tanggal', t.tanggalLabel ?? '-'),
                      _detailRow('Tujuan / Sumber', t.tujuanDistribusiNama ?? t.keteranganDisplay),
                      if ((t.catatan ?? '').isNotEmpty)
                        _detailRow('Catatan', t.catatan!),
                      _detailRow('Dicatat Oleh', t.dicatatOleh ?? 'Admin'),
                      _detailRow('Status', t.isAktif ? 'Aktif' : 'Dibatalkan'),
                      _detailRow('Saldo Stok', t.saldoDisplay),
                      if (t.fotoBukti != null && t.fotoBukti!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('Bukti Foto',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showFotoPreview(t.fotoBukti!),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Image.network(
                                  AppConstants.getStorageFileUrl(t.fotoBukti!),
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 160,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainer,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.zoom_in,
                                          color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text('Perbesar',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // ── Footer tombol Tutup ────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // HELPERS
  // ══════════════════════════════════════════════════════════════════════
  String _fmtKg(double v) {
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
              style: const TextStyle(color: AppColors.error, fontSize: 12)),
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
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
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
        parentContext: context,
        onSave: () {
          // Dialog berhasil menyimpan transaksi ke API
          // Refresh UI untuk menampilkan data terbaru
          _refresh();
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // PREVIEW FOTO BUKTI
  // ══════════════════════════════════════════════════════════════════════
  Future<void> _toggleStatus(TransaksiStokModel t) async {
    final isAktif = t.isAktif;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAktif ? 'Batalkan Transaksi' : 'Aktifkan Kembali'),
        content: Text(isAktif
            ? 'Transaksi ini akan ditandai sebagai dibatalkan dan saldo stok akan dihitung ulang. Lanjutkan?'
            : 'Transaksi ini akan diaktifkan kembali dan saldo stok akan dihitung ulang. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _transaksiService.toggleStatus(t.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAktif
              ? ' Transaksi dibatalkan'
              : ' Transaksi diaktifkan kembali'),
          duration: const Duration(seconds: 3),
        ),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal memperbarui status: $e')),
      );
    }
  }

  void _showFotoPreview(String fotoPath) {
    // Build image URL dari path database
    // Database simpan: "bukti-distribusi/1781358313_26bd614233f90.png"
    // Gunakan helper dari AppConstants untuk build URL
    String imageUrl = AppConstants.getStorageFileUrl(fotoPath);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image,
                                color: Colors.white70, size: 48),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Gagal memuat foto\n\nPath: $fotoPath\nURL: $imageUrl\n\nError: $error\n\n⚠️ Pastikan telah jalankan: php artisan storage:link',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
