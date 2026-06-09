// lib/screens/panen_screen.dart
// Disesuaikan penuh dengan Web Laravel (pangan_web):
//  - Dropdown Petani dari API (nama + luas lahan, sesuai web)
//  - Komoditas: hanya Padi & Jagung
//  - Riwayat: Petani | Tonase Gabah | Beras Hasil | Musim | Tanggal
//  - Data terhubung ke API Laravel

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_top_bar.dart';
import '../models/panen_model.dart';
import '../models/petani_model.dart';
import '../services/panen_service.dart';
import '../services/api_service.dart';

// ── Musim Tanam helper ────────────────────────────────────────────────
class _MusimOption {
  final String value;
  final String label;
  const _MusimOption(this.value, this.label);
}

const _musimOptions = [
  _MusimOption('kemarau', 'Kemarau'),
  _MusimOption('hujan', 'Hujan'),
];

// ── Hanya Padi & Jagung sesuai web ───────────────────────────────────
const _komoditasList = ['Padi', 'Jagung'];

// ── Screen ────────────────────────────────────────────────────────────

class PanenScreen extends StatefulWidget {
  const PanenScreen({super.key});

  @override
  State<PanenScreen> createState() => _PanenScreenState();
}

class _PanenScreenState extends State<PanenScreen> {
  final PanenService _panenService = PanenService();
  final ApiService _api = ApiService();

  // Form state
  PetaniModel? _selectedPetani;
  String? _selectedMusim;
  String _selectedKomoditas = 'Padi';
  double _tonaseGabah = 0.0;
  double _rasioKonversi = 61.5;
  final _tanggalCtrl = TextEditingController();
  final _tonaseCtrl = TextEditingController();
  final _rasioCtrl = TextEditingController(text: '61.5');
  final _catatanCtrl = TextEditingController();

  // Data
  List<PanenModel> _riwayat = [];
  List<PetaniModel> _petaniList = [];
  bool _isLoadingRiwayat = true;
  bool _isLoadingPetani = true;
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
    _loadPetani();
    _loadRiwayat();
  }

  @override
  void dispose() {
    _tanggalCtrl.dispose();
    _tonaseCtrl.dispose();
    _rasioCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  // ── Date helpers ──────────────────────────────────────────────────

  String _todayFormatted() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  /// Parse dd/MM/yyyy → yyyy-MM-dd untuk Laravel
  String? _parseDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    } catch (_) {}
    return null;
  }

  // ── Data loading ──────────────────────────────────────────────────

  /// Load semua petani (semua halaman) seperti web
  Future<void> _loadPetani() async {
    setState(() => _isLoadingPetani = true);
    try {
      List<PetaniModel> allPetani = [];
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final data =
            await _api.get('petani?page=$page') as Map<String, dynamic>;
        final list = (data['data'] as List<dynamic>)
            .map((e) => PetaniModel.fromJson(e as Map<String, dynamic>))
            .toList();
        allPetani.addAll(list);

        // Cek apakah ada halaman berikutnya
        final meta = data['meta'] as Map<String, dynamic>?;
        final lastPage = meta?['last_page'] as int? ?? 1;
        hasMore = page < lastPage;
        page++;
      }

      if (mounted) {
        setState(() {
          _petaniList = allPetani;
          _isLoadingPetani = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPetani = false);
    }
  }

  Future<void> _loadRiwayat() async {
    setState(() => _isLoadingRiwayat = true);
    try {
      final list = await _panenService.getAll();
      if (mounted) {
        setState(() {
          _riwayat = list;
          _isLoadingRiwayat = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRiwayat = false);
    }
  }

  // ── Label petani untuk dropdown (nama saja) ─────────────────────

  String _petaniDropdownLabel(PetaniModel p) {
    return p.nama;
  }

  // ── Save / Delete ─────────────────────────────────────────────────

  Future<void> _simpanPanen() async {
    if (_selectedPetani == null) {
      _snack('Pilih petani terlebih dahulu', isError: true);
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

    // Gunakan lahan pertama dari petani (relasi Laravel)
    final lahanId = _selectedPetani!.lahan.isNotEmpty
        ? _selectedPetani!.lahan.first.id
        : null;

    setState(() => _isSaving = true);
    try {
      await _panenService.create({
        if (lahanId != null) 'lahan_id': lahanId,
        'petani_id': _selectedPetani!.id,
        'tanggal_panen': tanggal,
        'jumlah_gabah': _tonaseGabah,
        'konversi_factor': _rasioKonversi / 100,
        'musim_tanam': _selectedMusim,
        'komoditas': _selectedKomoditas,
        'catatan': _catatanCtrl.text.trim().isEmpty
            ? null
            : _catatanCtrl.text.trim(),
      });

      // Reset form
      _tonaseCtrl.clear();
      _catatanCtrl.clear();
      _rasioCtrl.text = '61.5';
      setState(() {
        _selectedPetani = null;
        _selectedMusim = null;
        _selectedKomoditas = 'Padi';
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



  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────

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
            // ── Header ────────────────────────────────────────────
            const Text(
              'Pencatatan Panen',
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            const Text(
              'Input tonase panen dengan konversi gabah → beras otomatis',
              style:
                  TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // ── Form Card ─────────────────────────────────────────
            _card(
              title: 'Catat Hasil Panen Baru',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Pilih Petani (sesuai web) ─────────────────
                  _label('Petani *'),
                  const SizedBox(height: 8),
                  _isLoadingPetani
                      ? const Center(
                          child: Padding(
                          padding: EdgeInsets.all(8),
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ))
                      : _inputBox(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<PetaniModel>(
                              value: _selectedPetani,
                              hint: const Text('Pilih petani...',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.onSurfaceVariant)),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: AppColors.onSurfaceVariant),
                              items: _petaniList
                                  .map((p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(
                                          _petaniDropdownLabel(p),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.onSurface),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(() {
                                _selectedPetani = val;
                                // Auto-isi komoditas dari data petani
                                // (hanya jika komoditas ada di daftar Padi/Jagung)
                                if (val?.komoditas != null &&
                                    _komoditasList
                                        .contains(val!.komoditas)) {
                                  _selectedKomoditas = val.komoditas!;
                                }
                              }),
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),

                  // ── Musim Tanam ───────────────────────────────
                  _label('Musim Tanam *'),
                  const SizedBox(height: 8),
                  _inputBox(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMusim,
                        hint: const Text('Pilih musim tanam...',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant)),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.onSurfaceVariant),
                        items: _musimOptions
                            .map((m) => DropdownMenuItem(
                                  value: m.value,
                                  child: Text(m.label,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.onSurface)),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedMusim = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Tanggal Panen ─────────────────────────────
                  _label('Tanggal Panen *'),
                  const SizedBox(height: 8),
                  _inputBox(
                    child: TextFormField(
                      controller: _tanggalCtrl,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'DD/MM/YYYY',
                        suffixIcon: Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.onSurfaceVariant,
                            size: 18),
                      ),
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurface),
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
                  const SizedBox(height: 16),

                  // ── Tonase Gabah ──────────────────────────────
                  _label('Tonase Gabah (kg) *'),
                  const SizedBox(height: 4),
                  const Text('Berat gabah basah setelah panen',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  _inputBox(
                    child: Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tonaseCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: 3000',
                            hintStyle: TextStyle(
                                color: AppColors.onSurfaceVariant),
                            border: InputBorder.none,
                            isDense: true,
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
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // ── Rasio Konversi ────────────────────────────
                  _label('Rasio Konversi (%)'),
                  const SizedBox(height: 4),
                  const Text(
                      'Default sistem: 61,5% (dapat disesuaikan per batch)',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  _inputBox(
                    child: TextFormField(
                      controller: _rasioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.onSurface),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Komoditas (hanya Padi & Jagung) ──────────
                  _label('Komoditas'),
                  const SizedBox(height: 8),
                  _inputBox(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedKomoditas,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.onSurfaceVariant),
                        items: _komoditasList
                            .map((k) => DropdownMenuItem(
                                  value: k,
                                  child: Text(k,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.onSurface)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(
                            () => _selectedKomoditas = val ?? 'Padi'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Catatan ───────────────────────────────────
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
                        hintText:
                            'Kondisi panen, cuaca, dll. (opsional)',
                        hintStyle: TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.onSurface),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Estimasi Beras ────────────────────────────
                  if (_tonaseGabah > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 44,
                          height: 44,
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
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(
                                '${_estimasiBeras.toStringAsFixed(0)} kg',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${_rasioKonversi.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Tombol Simpan ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _simpanPanen,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Icon(Icons.save_outlined),
                      label: const Text('Simpan Catatan Panen',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
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

            // ── Riwayat Panen Terbaru (sesuai tabel web) ──────────
            _card(
              title: 'Riwayat Panen Terbaru',
              subtitle: '${_riwayat.length} entri terbaru',
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
                            children: [
                              _tableHeader(),
                              const SizedBox(height: 4),
                              ..._riwayat.map((r) => _riwayatRow(r)),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tabel Header (kolom = web) ────────────────────────────────────

  Widget _tableHeader() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('PETANI',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.onSurfaceVariant))),
          Expanded(
              flex: 3,
              child: Text('TONASE GABAH',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.onSurfaceVariant))),
          Expanded(
              flex: 3,
              child: Text('BERAS HASIL',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.onSurfaceVariant))),
          Expanded(
              flex: 3,
              child: Text('MUSIM',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.onSurfaceVariant))),
          Expanded(
              flex: 3,
              child: Text('TANGGAL',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.onSurfaceVariant))),
          SizedBox(width: 24),
        ],
      ),
    );
  }

  // ── Riwayat Row ───────────────────────────────────────────────────

  Widget _riwayatRow(PanenModel r) {
    final musimLabel = r.musimLabel;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          bottom: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.4), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Petani (nama dari API, bukan nama lahan)
          Expanded(
            flex: 3,
            child: Text(
              r.namaPetani,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Tonase Gabah
          Expanded(
            flex: 3,
            child: Text(
              '${r.jumlahGabah.toStringAsFixed(0)} kg',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.onSurface),
            ),
          ),
          // Beras Hasil (hijau bold sesuai web)
          Expanded(
            flex: 3,
            child: Text(
              r.konversiBeras != null
                  ? '${r.konversiBeras!.toStringAsFixed(0)} kg'
                  : '—',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ),
          // Musim (badge pill sesuai web)
          Expanded(
            flex: 3,
            child: musimLabel != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        musimLabel,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          // Tanggal
          Expanded(
            flex: 3,
            child: Text(
              r.tanggalPanen,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Widget _card(
      {required String title,
      String? subtitle,
      required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.04),
              blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant)),
          ],
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _inputBox({required Widget child}) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface));
  }
}
