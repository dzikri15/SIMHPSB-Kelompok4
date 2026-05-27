// lib/screens/laporan_screen.dart
// Halaman Laporan SIMHPSB — Panen / Stok / Margin
// UI Flutter, data terhubung ke Laravel API

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_top_bar.dart';
import '../services/laporan_service.dart';

// ── Warna aksen tambahan ─────────────────────────────────────────────────
const _amber = Color(0xFFB45309);
const _amberBg = Color(0xFFFEF3C7);
const _amberBorder = Color(0xFFFCD34D);
const _green = AppColors.primary;
const _greenBg = AppColors.primaryContainer;

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen>
    with SingleTickerProviderStateMixin {
  final LaporanService _service = LaporanService();

  // Tab
  late final TabController _tabCtrl;
  int _activeTab = 0; // 0=Panen 1=Stok 2=Margin

  // Filter shared
  DateTime _dari = DateTime.now().copyWith(day: 1);
  DateTime _sampai = DateTime.now();

  // Panen filter
  String _petaniId = 'semua';
  List<Map<String, dynamic>> _petaniList = [];

  // Stok filter
  String _komoditas = 'semua';

  // Data futures
  Future<Map<String, dynamic>>? _futurePanen;
  Future<Map<String, dynamic>>? _futureStok;
  Future<Map<String, dynamic>>? _futureMargin;


  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      setState(() => _activeTab = _tabCtrl.index);
    });
    _loadPetani();
    _tampilkan();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPetani() async {
    try {
      final list = await _service.getPetaniDropdown();
      setState(() => _petaniList = list);
    } catch (_) {}
  }

  String get _dariStr =>
      '${_dari.year}-${_dari.month.toString().padLeft(2, '0')}-${_dari.day.toString().padLeft(2, '0')}';
  String get _sampaiStr =>
      '${_sampai.year}-${_sampai.month.toString().padLeft(2, '0')}-${_sampai.day.toString().padLeft(2, '0')}';

  void _tampilkan() {
    setState(() {
      _futurePanen = _service.getLaporanPanen(
        petaniId: _petaniId == 'semua' ? null : _petaniId,
        dari: _dariStr,
        sampai: _sampaiStr,
      );
      _futureStok = _service.getLaporanStok(
        komoditas: _komoditas == 'semua' ? null : _komoditas,
        dari: _dariStr,
        sampai: _sampaiStr,
      );
      _futureMargin = _service.getLaporanMargin(
        petaniId: _petaniId == 'semua' ? null : _petaniId,
        dari: _dariStr,
        sampai: _sampaiStr,
      );
    });
  }

  Future<void> _pickDate(bool isDari) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDari ? _dari : _sampai,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isDari) {
        _dari = picked;
      } else {
        _sampai = picked;
      }
    });
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtKg(dynamic v) {
    final n = (v as num?)?.toDouble() ?? 0.0;
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} ton';
    }
    return '${n.toStringAsFixed(0)} kg';
  }

  String _fmtRp(dynamic v) {
    final n = (v as num?)?.toDouble() ?? 0.0;
    if (n == 0) return 'Rp 0';
    return 'Rp ${n.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildPanenTab(),
                _buildStokTab(),
                _buildMarginTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Rekapitulasi data panen, stok, dan margin per periode',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Date from
              Expanded(child: _dateField('Dari Tanggal', _dari, () => _pickDate(true))),
              const SizedBox(width: 8),
              // Date to
              Expanded(child: _dateField('Sampai Tanggal', _sampai, () => _pickDate(false))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Petani or komoditas based on tab
              Expanded(child: _activeTab == 1 ? _komoditasDropdown() : _petaniDropdown()),
              const SizedBox(width: 8),
              // Tampilkan button
              SizedBox(
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: _tampilkan,
                  icon: const Icon(Icons.filter_alt, size: 16),
                  label: const Text('Tampilkan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateField(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(10),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                  Text(_fmt(date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                ],
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _petaniDropdown() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _petaniId,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          icon: const Icon(Icons.expand_more, size: 16, color: AppColors.outline),
          onChanged: (v) => setState(() => _petaniId = v ?? 'semua'),
          items: [
            const DropdownMenuItem(value: 'semua', child: Text('Semua Petani')),
            ..._petaniList.map((p) => DropdownMenuItem(
                  value: p['id'].toString(),
                  child: Text(p['nama'] as String? ?? '-', overflow: TextOverflow.ellipsis),
                )),
          ],
        ),
      ),
    );
  }

  Widget _komoditasDropdown() {
    const komoditasList = ['semua', 'beras', 'gabah', 'jagung'];
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _komoditas,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          icon: const Icon(Icons.expand_more, size: 16, color: AppColors.outline),
          onChanged: (v) => setState(() => _komoditas = v ?? 'semua'),
          items: komoditasList.map((k) => DropdownMenuItem(
                value: k,
                child: Text(k == 'semua' ? 'Semua Komoditas' : k[0].toUpperCase() + k.substring(1)),
              )).toList(),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = ['Laporan Panen', 'Laporan Stok', 'Laporan Margin'];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.brandDark,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: tabs.map((t) => Tab(height: 36, text: t)).toList(),
      ),
    );
  }

  // ── TAB PANEN ────────────────────────────────────────────────────────────

  Widget _buildPanenTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futurePanen,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loadingWidget();
        if (snap.hasError) return _errorWidget(snap.error.toString());
        final data = snap.data ?? {};
        final summary = data['summary'] as Map<String, dynamic>? ?? {};
        final detail = (data['detail'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final totalPanen = summary['total_panen'];
        final totalDistribusi = summary['total_distribusi'];
        final estimasiMargin = summary['estimasi_margin'];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // Summary cards
            Row(children: [
              Expanded(child: _summaryCard('TOTAL PANEN', _fmtKg(totalPanen), 'gabah periode ini', const Color(0xFF1565C0), const Color(0xFFEFF6FF))),
              const SizedBox(width: 8),
              Expanded(child: _summaryCard('TOTAL DISTRIBUSI', _fmtKg(totalDistribusi), 'beras periode ini', _green, _greenBg)),
            ]),
            const SizedBox(height: 8),
            _summaryCard('ESTIMASI MARGIN', _fmtRp(estimasiMargin), '≈ Rp 0/kg × distribusi', _amber, _amberBg),
            const SizedBox(height: 16),

            // Grafik (simplified bar)            const SizedBox(height: 16),

            // Detail table
            _buildDetailPanen(detail),
          ],
        );
      },
    );
  }


  Widget _buildDetailPanen(List<Map<String, dynamic>> detail) {
    return _sectionCard(
      title: 'Detail Laporan Panen per Petani',
      child: detail.isEmpty
          ? _emptyState('Tidak ada data panen pada periode ini')
          : Column(
              children: [
                _tableHeader(['PETANI', 'LAHAN', 'TONASE', 'BERAS', 'TANGGAL', 'HPP EST.']),
                ...detail.map((row) => _panenRow(row)),
              ],
            ),
    );
  }

  Widget _panenRow(Map<String, dynamic> row) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(row['petani'] as String? ?? '-', style: _rowStyle())),
          Expanded(flex: 2, child: Text('${row['lahan'] ?? '-'} m²', style: _rowStyle())),
          Expanded(flex: 2, child: Text(_fmtKg(row['jumlah_gabah']), style: _rowStyle())),
          Expanded(flex: 2, child: Text(_fmtKg(row['beras_dihasilkan']), style: _rowStyle())),
          Expanded(flex: 3, child: Text(_shortDatetime(row['tanggal_panen'] as String? ?? '-'), style: _rowStyle(small: true))),
          Expanded(flex: 2, child: Text(_fmtRp(row['hpp_estimasi']), style: _rowStyle(small: true))),
        ],
      ),
    );
  }

  // ── TAB STOK ─────────────────────────────────────────────────────────────

  Widget _buildStokTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureStok,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loadingWidget();
        if (snap.hasError) return _errorWidget(snap.error.toString());
        final data = snap.data ?? {};
        final summary = data['summary'] as Map<String, dynamic>? ?? {};
        final detail = (data['detail'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final totalStok = summary['total_stok'];
        final gudangTerdata = summary['gudang_terdata'];
        final stokKurang = summary['stok_kurang'];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            Row(children: [
              Expanded(child: _summaryCard('TOTAL STOK', _fmtKg(totalStok), 'semua komoditas periode ini', _green, _greenBg)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCard('GUDANG TERDATA', '${gudangTerdata ?? 0}', 'lokasi stok aktif', const Color(0xFF1565C0), const Color(0xFFEFF6FF))),
            ]),
            const SizedBox(height: 8),
            _summaryCard(
              'STOK KURANG',
              '${stokKurang ?? 0}',
              'entry di bawah batas minimum',
              _amber, _amberBg,
              badge: (stokKurang ?? 0) > 0 ? '!' : null,
            ),
            const SizedBox(height: 16),            const SizedBox(height: 16),

            _buildDetailStok(detail),
          ],
        );
      },
    );
  }


  Widget _buildDetailStok(List<Map<String, dynamic>> detail) {
    return _sectionCard(
      title: 'Detail Laporan Stok',
      child: detail.isEmpty
          ? _emptyState('Tidak ada data stok pada periode ini')
          : Column(
              children: [
                _tableHeader(['GUDANG', 'KOMODITAS', 'JUMLAH STOK', 'BATAS MIN.', 'UPDATE', 'STATUS']),
                ...detail.map((row) => _stokRow(row)),
              ],
            ),
    );
  }

  Widget _stokRow(Map<String, dynamic> row) {
    final status = (row['status'] as String? ?? 'cukup').toLowerCase();
    final isCukup = status == 'cukup';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(row['gudang'] as String? ?? '-', style: _rowStyle())),
          Expanded(flex: 2, child: Text(row['komoditas'] as String? ?? '-', style: _rowStyle())),
          Expanded(flex: 2, child: Text(_fmtKg(row['jumlah_stok']), style: _rowStyle())),
          Expanded(flex: 2, child: Text(_fmtKg(row['batas_minimum']), style: _rowStyle())),
          Expanded(flex: 3, child: Text(
            _shortDatetime(row['tanggal_update'] as String? ?? '-'),
            style: _rowStyle(small: true),
          )),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isCukup ? _greenBg : _amberBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isCukup ? 'Cukup' : 'Kurang',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isCukup ? _green : _amber,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortDatetime(String dt) {
    if (dt.length > 10) return dt.substring(0, 10);
    return dt;
  }

  // ── TAB MARGIN ───────────────────────────────────────────────────────────

  Widget _buildMarginTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureMargin,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loadingWidget();
        if (snap.hasError) return _errorWidget(snap.error.toString());
        final data = snap.data ?? {};
        final summary = data['summary'] as Map<String, dynamic>? ?? {};
        final detail = (data['detail'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final totalDistribusi = summary['total_distribusi'];
        final totalPanen = summary['total_panen'];
        final estimasiMargin = summary['estimasi_margin'];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            Row(children: [
              Expanded(child: _summaryCard('TOTAL DISTRIBUSI', _fmtKg(totalDistribusi), 'beras periode ini', _green, _greenBg)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCard('TOTAL PANEN', _fmtKg(totalPanen), 'gabah periode ini', const Color(0xFF1565C0), const Color(0xFFEFF6FF))),
            ]),
            const SizedBox(height: 8),
            _summaryCard('ESTIMASI MARGIN', _fmtRp(estimasiMargin), 'berdasarkan HPP aktif', _amber, _amberBg),
            const SizedBox(height: 16),            const SizedBox(height: 16),

            _buildDetailMargin(detail),
          ],
        );
      },
    );
  }


  Widget _buildDetailMargin(List<Map<String, dynamic>> detail) {
    return _sectionCard(
      title: 'Detail Laporan Margin per Panen',
      child: detail.isEmpty
          ? _emptyState('Tidak ada data margin pada periode ini')
          : Column(
              children: [
                _tableHeader(['PETANI', 'LAHAN', 'TONASE', 'BERAS', 'TANGGAL', 'HPP EST.', 'STATUS']),
                ...detail.map((row) => _marginRow(row)),
              ],
            ),
    );
  }

  Widget _marginRow(Map<String, dynamic> row) {
    final status = (row['status'] as String? ?? 'selesai').toLowerCase();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(row['petani'] as String? ?? '-', style: _rowStyle())),
          Expanded(flex: 2, child: Text('${row['lahan'] ?? '-'} m²', style: _rowStyle())),
          Expanded(flex: 2, child: Text(_fmtKg(row['jumlah_gabah']), style: _rowStyle())),
          Expanded(flex: 2, child: Text(_fmtKg(row['beras_dihasilkan']), style: _rowStyle())),
          Expanded(flex: 3, child: Text(_shortDatetime(row['tanggal_panen'] as String? ?? '-'), style: _rowStyle(small: true))),
          Expanded(flex: 2, child: Text(_fmtRp(row['hpp_estimasi']), style: _rowStyle(small: true))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: _greenBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _green),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared widgets ───────────────────────────────────────────────────────

  Widget _summaryCard(String label, String value, String sub, Color color, Color bg, {String? badge}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border(top: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: color)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.onSurface, letterSpacing: -0.5),
                ),
              ),
              if (badge != null)
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(color: _amberBg, shape: BoxShape.circle, border: Border.all(color: _amberBorder)),
                  child: Center(child: Text(badge, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _amber))),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _tableHeader(List<String> cols) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: Row(
        children: cols.map((c) {
          final flex = c == 'PETANI' || c == 'GUDANG' ? 3 : (c == 'TANGGAL' || c == 'UPDATE' ? 3 : 2);
          return Expanded(
            flex: flex,
            child: Text(
              c,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.onSurfaceVariant),
            ),
          );
        }).toList(),
      ),
    );
  }

  TextStyle _rowStyle({bool small = false}) => TextStyle(
    fontSize: small ? 10 : 11,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );



  Widget _loadingWidget() => const Center(
    child: Padding(
      padding: EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 12),
          Text('Memuat laporan...', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
        ],
      ),
    ),
  );

  Widget _errorWidget(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.outline),
          const SizedBox(height: 12),
          const Text('Gagal memuat data', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 4),
          Text(msg, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _tampilkan,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Coba Lagi'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    ),
  );

  Widget _emptyState(String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 36, color: AppColors.outline),
          const SizedBox(height: 8),
          Text(msg, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    ),
  );
}
