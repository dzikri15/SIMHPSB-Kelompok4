// lib/widgets/catat_transaksi_dialog.dart
// Mengirim field yang sesuai dengan Api\StokController@catatTransaksi

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../services/transaksi_stok_service.dart';

class CatatTransaksiDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const CatatTransaksiDialog({super.key, required this.onSave});

  @override
  State<CatatTransaksiDialog> createState() => _CatatTransaksiDialogState();
}

class _CatatTransaksiDialogState extends State<CatatTransaksiDialog> {
  final TransaksiStokService _service = TransaksiStokService();

  String? _selectedJenis;
  String? _selectedKomoditas;
  final _jumlahCtrl   = TextEditingController();
  final _sumberCtrl   = TextEditingController();
  final _catatanCtrl  = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  late final List<String> _jenisList     = _service.getJenisTransaksi();
  late final List<String> _komoditasList = _service.getKomoditas();

  @override
  void dispose() {
    _jumlahCtrl.dispose();
    _sumberCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _handleSave() {
    if (_selectedJenis == null) {
      _snack('Pilih jenis transaksi'); return;
    }
    if (_selectedKomoditas == null) {
      _snack('Pilih komoditas'); return;
    }
    final jumlah = double.tryParse(_jumlahCtrl.text.replaceAll(',', '.'));
    if (jumlah == null || jumlah <= 0) {
      _snack('Jumlah harus lebih dari 0'); return;
    }
    if (_sumberCtrl.text.trim().isEmpty) {
      _snack('Isikan sumber / tujuan distribusi'); return;
    }

    final data = {
      'jenis_transaksi':   _selectedJenis!.toLowerCase(),   // ← diperbaiki
      'komoditas':         _selectedKomoditas,
      'jumlah':            jumlah,
      'tanggal':           DateFormat('yyyy-MM-dd').format(_selectedDate),
      'keterangan':        _sumberCtrl.text.trim(),          // ← diperbaiki
      'catatan':           _catatanCtrl.text.trim().isEmpty
                               ? null
                               : _catatanCtrl.text.trim(),
    };

    setState(() => _isSaving = true);
    widget.onSave(data);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandDark.withValues(alpha: 0.18),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_box, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Catat Transaksi Stok',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface)),
                        Text('Mutasi masuk / keluar gudang',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close,
                        color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            // ── Form Body ──────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Jenis Transaksi (masuk / keluar)
                    _label('Jenis Transaksi'),
                    const SizedBox(height: 8),
                    Row(
                      children: _jenisList.map((j) {
                        final isMasuk = j.toLowerCase() == 'masuk';
                        final isSelected = _selectedJenis == j;
                        final color = isMasuk
                            ? const Color(0xFF1565C0)
                            : AppColors.error;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedJenis = j),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: EdgeInsets.only(
                                  right: isMasuk ? 8 : 0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color
                                    : color.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: isSelected
                                        ? color
                                        : color.withValues(alpha: 0.2),
                                    width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isMasuk
                                        ? Icons.login_rounded
                                        : Icons.logout_rounded,
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(j,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: isSelected
                                              ? Colors.white
                                              : color)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Komoditas
                    _label('Komoditas'),
                    const SizedBox(height: 8),
                    _dropdownField(
                      value: _selectedKomoditas,
                      hint: 'Pilih komoditas',
                      items: _komoditasList,
                      onChanged: (v) => setState(() => _selectedKomoditas = v),
                    ),
                    const SizedBox(height: 18),

                    // Jumlah + Tanggal
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Jumlah (kg)'),
                            const SizedBox(height: 8),
                            _textField(
                              controller: _jumlahCtrl,
                              hint: '0',
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[\d,.]'))
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Tanggal'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  border: Border.all(
                                      color: AppColors.outlineVariant),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16,
                                      color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(_selectedDate),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 18),

                    // Sumber / Tujuan Distribusi
                    _label('Sumber / Tujuan Distribusi'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _sumberCtrl,
                      hint: 'Contoh: Petani Budi, MBG Dapur 1, dll.',
                    ),
                    const SizedBox(height: 18),

                    // Catatan Tambahan
                    _label('Catatan Tambahan (opsional)'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _catatanCtrl,
                      hint: 'Catatan tambahan...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Footer Buttons ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Simpan Transaksi',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: 0.3));

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: AppColors.onSurfaceVariant, fontSize: 13),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint,
            style: const TextStyle(
                color: AppColors.onSurfaceVariant, fontSize: 13)),
        isExpanded: true,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(12),
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
