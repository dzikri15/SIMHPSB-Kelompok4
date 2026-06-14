// lib/widgets/catat_transaksi_dialog.dart
// Dialog untuk catat transaksi stok (masuk/keluar)
// Langsung melakukan API call ke Api\StokController@catat
// Panggil onSave callback untuk parent refresh setelah sukses

import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../services/transaksi_stok_service.dart';
import '../services/tujuan_distribusi_service.dart';
import '../services/stok_service.dart';
import '../models/tujuan_distribusi_model.dart';

class CatatTransaksiDialog extends StatefulWidget {
  final Function()? onSave;  // Callback ketika transaksi berhasil disimpan (untuk refresh parent)

  const CatatTransaksiDialog({super.key, this.onSave});

  @override
  State<CatatTransaksiDialog> createState() => _CatatTransaksiDialogState();
}

class _CatatTransaksiDialogState extends State<CatatTransaksiDialog> {
  final TransaksiStokService _service = TransaksiStokService();
  final TujuanDistribusiService _tujuanService = TujuanDistribusiService();
  final StokService _stokService = StokService();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedJenis;
  String? _selectedKomoditas;
  int? _selectedTujuanId;
  String? _selectedTujuanNama;  // Tambah untuk track nama tujuan
  io.File? _selectedFile;  // Native only
  XFile? _selectedXFile;   // Web support

  final _jumlahCtrl   = TextEditingController();
  final _sumberCtrl   = TextEditingController();
  final _catatanCtrl  = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  late final List<String> _jenisList     = _service.getJenisTransaksi();
  late final List<String> _komoditasList = _service.getKomoditas();
  late final Future<List<TujuanDistribusiModel>> _tujuanFuture = _tujuanService.getAll();

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
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: Theme.of(ctx).colorScheme.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickFile() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedXFile = pickedFile;
          // Only convert to io.File on native platform
          if (!kIsWeb) {
            _selectedFile = io.File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      _snack('Gagal memilih foto: $e');
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
      _selectedXFile = null;
    });
  }

  Future<void> _handleSave() async {
    if (_selectedJenis == null) {
      _snack('Pilih jenis transaksi');
      return;
    }
    if (_selectedKomoditas == null) {
      _snack('Pilih komoditas');
      return;
    }
    final jumlah = double.tryParse(_jumlahCtrl.text.replaceAll(',', '.'));
    if (jumlah == null || jumlah <= 0) {
      _snack('Jumlah harus lebih dari 0');
      return;
    }

    // Validasi khusus untuk transaksi keluar
    if (_selectedJenis == 'Keluar') {
      if (_selectedTujuanId == null) {
        _snack('Pilih tujuan distribusi');
        return;
      }
    }

    // Gabungkan tujuan distribusi + sumber menjadi 1 field keterangan
    final StringBuffer keteranganBuffer = StringBuffer();
    
    // Jika transaksi keluar, tambahkan tujuan distribusi
    if (_selectedJenis == 'Keluar' && _selectedTujuanNama != null) {
      keteranganBuffer.write(_selectedTujuanNama);
    }
    
    // Tambahkan sumber/tujuan dari text input
    final sumberText = _sumberCtrl.text.trim();
    if (sumberText.isNotEmpty) {
      if (keteranganBuffer.isNotEmpty) {
        keteranganBuffer.write(' / ');
      }
      keteranganBuffer.write(sumberText);
    }

    final data = {
      'jenis_transaksi': _selectedJenis!.toLowerCase(),
      'komoditas': _selectedKomoditas,
      'jumlah': jumlah,
      'tanggal': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'keterangan': keteranganBuffer.toString().isEmpty
          ? null
          : keteranganBuffer.toString(),
      'catatan': _catatanCtrl.text.trim().isEmpty
          ? null
          : _catatanCtrl.text.trim(),
    };

    setState(() => _isSaving = true);

    try {
      // Kirim ke API dengan file (jika ada), via bytes agar bekerja di web & native
      final fotoBytes = _selectedXFile != null
          ? await _selectedXFile!.readAsBytes()
          : null;
      await _service.create(
        data,
        fotoBytes,
        fotoBuktiName: _selectedXFile?.name,
      );
      
      if (!mounted) return;
      
      _snack('Transaksi berhasil disimpan');
      
      // Panggil callback parent untuk refresh
      widget.onSave?.call();
      
      // Close dialog
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _snack('Gagal menyimpan: $e');
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildTujuanDropdown() {
    return FutureBuilder<List<TujuanDistribusiModel>>(
      future: _tujuanFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snap.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gagal memuat tujuan distribusi. Pastikan backend berjalan.',
                style: TextStyle(fontSize: 12, color: Colors.red[400]),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () => setState(() {}), // trigger rebuild untuk retry
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Coba lagi', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          );
        }

        final tujuanList = snap.data ?? [];
        if (tujuanList.isEmpty) {
          return Text('Tidak ada tujuan distribusi',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]));
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<int>(
            value: _selectedTujuanId,
            hint: Text('Pilih tujuan distribusi',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13)),
            isExpanded: true,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(12),
            style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface),
            items: tujuanList
                .map((t) => DropdownMenuItem<int>(
                      value: t.id,
                      child: Text(t.nama),
                    ))
                .toList(),
            onChanged: (selectedId) {
              if (selectedId != null) {
                // Find nama dari tujuan list
                final selected = tujuanList.firstWhere(
                  (t) => t.id == selectedId,
                  orElse: () => TujuanDistribusiModel(id: selectedId, nama: 'Unknown'),
                );
                setState(() {
                  _selectedTujuanId = selectedId;
                  _selectedTujuanNama = selected.nama;
                });
              }
            },
            dropdownColor: Theme.of(context).colorScheme.surface,
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width > 600 ? 500 : MediaQuery.of(context).size.width - 24,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
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
                    child: Icon(Icons.add_box, 
                        color: Theme.of(context).colorScheme.onPrimary, 
                        size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Catat Transaksi Stok',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface)),
                        Text('Mutasi masuk / keluar gudang',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                            ? AppColors.accentBlue
                            : AppColors.accentRed;
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
                                        ? AppColors.onPrimary
                                        : color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(j,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: isSelected
                                              ? AppColors.onPrimary
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
                            _label('Jumlah'),
                            const SizedBox(height: 8),
                            _textField(
                              controller: _jumlahCtrl,
                              hint: '0 kg',
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
                                  color: Theme.of(context).colorScheme.surface,
                                  border: Border.all(
                                      color: Theme.of(context).colorScheme.outline, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(children: [
                                  Icon(Icons.calendar_today,
                                      size: 18,
                                      color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(_selectedDate),
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
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

                    // Sumber / Tujuan Distribusi (label dinamis)
                    _label(_selectedJenis == 'Keluar' ? 'Sumber / Keterangan' : 'Sumber / Tujuan Distribusi'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _sumberCtrl,
                      hint: _selectedJenis == 'Keluar'
                          ? 'Contoh: Dari Petani Budi, Hasil panen, dll.'
                          : 'Contoh: Petani Budi, MBG Dapur 1, dll.',
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
                    const SizedBox(height: 18),

                    // Tujuan Distribusi (hanya untuk Keluar)
                    if (_selectedJenis == 'Keluar') ...[
                      _label('Tujuan Distribusi'),
                      const SizedBox(height: 8),
                      _buildTujuanDropdown(),
                      const SizedBox(height: 18),

                      // Bukti Pengiriman (Foto)
                      _label('Bukti Pengiriman (Foto)'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(Icons.photo_library),
                              label: Text(_selectedXFile != null
                                  ? 'File: ${_selectedXFile!.name}'
                                  : 'Pilih Foto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_selectedFile != null)
                            IconButton(
                              onPressed: _clearFile,
                              icon: const Icon(Icons.close),
                            ),
                        ],
                      ),
                      if (_selectedFile != null && !kIsWeb)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildImagePreview(_selectedFile!),
                          ),
                        ),
                      const SizedBox(height: 18),
                    ],

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
                      side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Batal',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600, fontSize: 14)),
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
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
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
      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  // Helper method to display image preview
  // Hanya untuk native, tidak support web
  Widget _buildImagePreview(io.File file) {
    if (kIsWeb) {
      return Container(
        height: 120,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(
          child: Text('Preview tidak didukung di web', 
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
      );
    }
    try {
      return Image.file(
        file,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Gagal memuat foto', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        height: 120,
        width: double.infinity,
        color: Colors.grey[300],
        child: Center(
          child: Text('Error: $e', style: const TextStyle(fontSize: 10)),
        ),
      );
    }
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
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
        isExpanded: true,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(12),
        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                ))
            .toList(),
        onChanged: onChanged,
        dropdownColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}