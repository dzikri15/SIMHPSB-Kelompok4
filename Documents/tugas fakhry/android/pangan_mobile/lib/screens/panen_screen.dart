// lib/screens/panen_screen.dart
// Terhubung penuh ke Laravel API (GET/POST/PUT/DELETE)

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_top_bar.dart';
import '../models/panen_model.dart';
import '../models/lahan_model.dart';
import '../services/panen_service.dart';
import '../services/api_service.dart';

class PanenScreen extends StatefulWidget {
  const PanenScreen({super.key});

  @override
  State<PanenScreen> createState() => _PanenScreenState();
}

class _PanenScreenState extends State<PanenScreen> {
  final PanenService _panenService = PanenService();
  final ApiService _api = ApiService();

  // Form state
  double _tonaseGabah = 0.0;
  double _rasioKonversi = 61.5;
  LahanModel? _selectedLahan;
  final _tanggalCtrl = TextEditingController();
  final _tonaseCtrl = TextEditingController();
  final _rasioCtrl = TextEditingController(text: '61.5');
  final _hargaCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();

  // Data
  List<PanenModel> _riwayat = [];
  List<LahanModel> _lahanList = [];
  bool _isLoadingRiwayat = true;
  bool _isLoadingLahan = true;
  bool _isSaving = false;

  double get _estimasiBeras => _tonaseGabah * (_rasioKonversi / 100);

  @override
  void initState() {
    super.initState();
    _tanggalCtrl.text = _todayFormatted();
    _tonaseCtrl.addListener(() {
      setState(() {
        _tonaseGabah = double.tryParse(_tonaseCtrl.text) ?? 0.0;
      });
    });
    _rasioCtrl.addListener(() {
      setState(() {
        _rasioKonversi =
            double.tryParse(_rasioCtrl.text.replaceAll(',', '.')) ?? 61.5;
      });
    });
    _loadLahan();
    _loadRiwayat();
  }

  @override
  void dispose() {
    _tanggalCtrl.dispose();
    _tonaseCtrl.dispose();
    _rasioCtrl.dispose();
    _hargaCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  String _todayFormatted() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  /// Parse dd/MM/yyyy → yyyy-MM-dd
  String? _parseDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    } catch (_) {}
    return null;
  }

  Future<void> _loadLahan() async {
    setState(() => _isLoadingLahan = true);
    try {
      final data = await _api.get('lahan?page=1') as Map<String, dynamic>;
      final list = (data['data'] as List<dynamic>)
          .map((e) => LahanModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() { _lahanList = list; _isLoadingLahan = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingLahan = false);
    }
  }

  Future<void> _loadRiwayat() async {
    setState(() => _isLoadingRiwayat = true);
    try {
      final list = await _panenService.getAll();
      if (mounted) setState(() { _riwayat = list; _isLoadingRiwayat = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingRiwayat = false);
    }
  }

  Future<void> _simpanPanen() async {
    if (_selectedLahan == null) {
      _snack('Pilih lahan terlebih dahulu', isError: true);
      return;
    }
    if (_tonaseGabah <= 0) {
      _snack('Tonase gabah harus lebih dari 0', isError: true);
      return;
    }
    final tanggal = _parseDate(_tanggalCtrl.text);
    if (tanggal == null) {
      _snack('Format tanggal: DD/MM/YYYY', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _panenService.create({
        'lahan_id': _selectedLahan!.id,
        'tanggal_panen': tanggal,
        'jumlah_gabah': _tonaseGabah,
        'harga_gabah_per_kg': _hargaCtrl.text.isNotEmpty
            ? double.tryParse(_hargaCtrl.text)
            : null,
        'konversi_factor': _rasioKonversi / 100,
        'catatan': _catatanCtrl.text.trim().isEmpty
            ? null
            : _catatanCtrl.text.trim(),
      });
      // Reset form
      _tonaseCtrl.clear();
      _hargaCtrl.clear();
      _catatanCtrl.clear();
      _rasioCtrl.text = '61.5';
      setState(() {
        _selectedLahan = null;
        _tonaseGabah = 0;
        _rasioKonversi = 61.5;
        _tanggalCtrl.text = _todayFormatted();
      });
      _snack('Panen berhasil disimpan');
      _loadRiwayat();
    } on ApiException catch (e) {
      _snack('Error: ${e.message}', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _hapusPanen(PanenModel panen) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data Panen?'),
        content: const Text('Data panen ini akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _panenService.delete(panen.id);
      _snack('Data panen dihapus');
      _loadRiwayat();
    } on ApiException catch (e) {
      _snack('Error: ${e.message}', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.primary,
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pencatatan Panen',
              style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.w800,
                  color: AppColors.onSurface, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            const Text(
              'Input tonase panen dengan konversi gabah → beras otomatis.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // ── Form Card ───────────────────────────────────────────
            _card(
              title: 'Catat Hasil Panen Baru',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pilih Lahan
                  _label('Lahan *'),
                  const SizedBox(height: 4),
                  const Text('Pilih lahan yang dipanen (terhubung ke data petani)',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  _isLoadingLahan
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ))
                      : _inputBox(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<LahanModel>(
                              value: _selectedLahan,
                              hint: const Text('Pilih lahan...',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.onSurfaceVariant)),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: AppColors.onSurfaceVariant),
                              items: _lahanList
                                  .map((l) => DropdownMenuItem(
                                        value: l,
                                        child: Text(
                                          '${l.namaLahan ?? 'Lahan ${l.id}'}'
                                          '${l.komoditas != null ? ' (${l.komoditas})' : ''}',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.onSurface),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedLahan = val),
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),

                  // Tanggal Panen
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Tanggal Panen *'),
                          const SizedBox(height: 8),
                          _inputBox(
                            child: TextFormField(
                              controller: _tanggalCtrl,
                              decoration: const InputDecoration(
                                border: InputBorder.none, isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'DD/MM/YYYY',
                                suffixIcon: Icon(Icons.calendar_today_outlined,
                                    color: AppColors.onSurfaceVariant, size: 18),
                              ),
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.onSurface),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  _tanggalCtrl.text =
                                      '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                }
                              },
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Harga Gabah/kg'),
                          const SizedBox(height: 8),
                          _inputBox(
                            child: TextFormField(
                              controller: _hargaCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none, isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Rp/kg',
                                hintStyle: TextStyle(
                                    color: AppColors.onSurfaceVariant),
                              ),
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Tonase Gabah
                  _label('Tonase Gabah (kg) *'),
                  const SizedBox(height: 4),
                  const Text('Berat gabah basah setelah panen',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  _inputBox(
                    child: Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tonaseCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: 3000',
                            hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                            border: InputBorder.none, isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.onSurface),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('kg',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Rasio Konversi
                  _label('Rasio Konversi (%)'),
                  const SizedBox(height: 4),
                  const Text('Default: 61.5% (dikirim ke server sebagai konversi_factor)',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  _inputBox(
                    child: TextFormField(
                      controller: _rasioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none, isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.onSurface),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Catatan
                  _label('Catatan'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _catatanCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Kondisi panen, cuaca, dll. (opsional)',
                        hintStyle: TextStyle(
                            fontSize: 13, color: AppColors.onSurfaceVariant),
                        border: InputBorder.none, isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.onSurface),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Estimasi
                  if (_tonaseGabah > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.calculate_outlined,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ESTIMASI BERAS HASIL',
                                  style: TextStyle(
                                      fontSize: 9, fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(
                                '${_estimasiBeras.toStringAsFixed(0)} kg',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w900,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Simpan
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _simpanPanen,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_outlined),
                      label: const Text('Simpan Catatan Panen',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Riwayat Panen ────────────────────────────────────────
            _card(
              title: 'Riwayat Panen',
              subtitle: '${_riwayat.length} catatan',
              child: _isLoadingRiwayat
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ))
                  : _riwayat.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('Belum ada riwayat panen.',
                                style: TextStyle(
                                    color: AppColors.onSurfaceVariant)),
                          ))
                      : RefreshIndicator(
                          onRefresh: _loadRiwayat,
                          child: Column(
                            children: _riwayat.map((r) => _riwayatTile(r)).toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _riwayatTile(PanenModel r) {
    final namaLahan = r.lahan?.namaLahan ?? 'Lahan ${r.lahanId}';
    final tanggal = r.tanggalPanen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaLahan,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Text(tanggal,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.onSurfaceVariant)),
                if (r.catatan != null && r.catatan!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(r.catatan!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.onSurfaceVariant),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${r.jumlahGabah.toStringAsFixed(0)} kg gabah',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(
                r.konversiBeras != null
                    ? '${r.konversiBeras!.toStringAsFixed(0)} kg beras'
                    : '-',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _hapusPanen(r),
                child: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  Widget _card({required String title, String? subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.onSurface.withOpacity(0.04), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700,
                  color: AppColors.onSurface)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _inputBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.onSurface));
  }
}
