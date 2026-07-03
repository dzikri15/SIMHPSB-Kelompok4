// lib/screens/panen_detail_screen.dart
// Halaman detail satu catatan panen
// Label: "Hasil" (bukan Tonase), "Penghasilan" (bukan Estimasi Nilai / Nilai)
// Menampilkan harga_gabah_per_kg sebagai snapshot historis (tidak dihitung ulang)

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/panen_model.dart';

class PanenDetailScreen extends StatelessWidget {
  final PanenModel panen;
  const PanenDetailScreen({super.key, required this.panen});

  /// Bisa dipanggil sebagai halaman penuh atau sebagai bottom sheet.
  static Future<void> showSheet(BuildContext context, PanenModel panen) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PanenDetailScreen(panen: panen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // ── Handle bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.grass_outlined,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Panen',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          panen.lahan?.namaLahan ?? 'Lahan #${panen.lahanId}',
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cs.outlineVariant),

            // ── Scrollable Content ────────────────────────────────────
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  // ── Stats chips row ───────────────────────────────
                  if (panen.musimLabel != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          panen.musimLabel!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ── Info rows ─────────────────────────────────────
                  _infoCard(context, [
                    _infoRow(context,
                        icon: Icons.person_outline,
                        label: 'Petani',
                        value: panen.namaPetani),
                    _infoRow(context,
                        icon: Icons.landscape_outlined,
                        label: 'Lahan',
                        value: panen.lahan?.namaLahan ?? 'Lahan #${panen.lahanId}'),
                    _infoRow(context,
                        icon: Icons.calendar_today_outlined,
                        label: 'Tanggal Panen',
                        value: _fmtTanggal(panen.tanggalPanen)),
                  ]),
                  const SizedBox(height: 12),

                  // ── Hasil & Konversi ──────────────────────────────
                  _sectionLabel(context, 'Hasil Panen'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          context,
                          icon: Icons.grain,
                          label: 'Hasil Gabah',   // LABEL BARU: "Hasil" bukan "Tonase"
                          value: '${panen.jumlahGabah.toStringAsFixed(0)} kg',
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Harga & Penghasilan ───────────────────────────
                  if (panen.hargaGabahPerKg != null && panen.hargaGabahPerKg! > 0) ...[
                    _infoCard(context, [
                      _infoRow(context,
                          icon: Icons.price_check_outlined,
                          label: 'Harga Gabah/kg (saat panen)',
                          value: _fmtRupiah(panen.hargaGabahPerKg!),
                          valueNote: '* harga historis, tidak berubah'),
                      _infoRow(context,
                          icon: Icons.payments_outlined,
                          label: 'Penghasilan',              // LABEL BARU: "Penghasilan" bukan "Estimasi Nilai"
                          value: _fmtRupiahLong(panen.penghasilan),
                          highlight: true),
                    ]),
                    const SizedBox(height: 12),
                  ],

                  // ── Catatan ───────────────────────────────────────
                  if (panen.catatan != null && panen.catatan!.isNotEmpty) ...[
                    _sectionLabel(context, 'Catatan'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        panen.catatan!,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Foto Bukti ────────────────────────────────────
                  if (panen.fotoBuktiUrl != null) ...[
                    _sectionLabel(context, 'Foto Bukti Panen'),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        panen.fotoBuktiUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        headers: const {
                          'Accept': 'image/*',
                        },
                        errorBuilder: (_, err, ___) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_outlined,
                                  color: cs.onSurfaceVariant, size: 40),
                              const SizedBox(height: 8),
                              Text('Foto tidak dapat dimuat',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              // URL debug — hapus setelah dipastikan berjalan
                              Text(
                                panen.fotoBuktiUrl!,
                                style: TextStyle(
                                    fontSize: 9,
                                    color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Container(
                                height: 180,
                                color: cs.surfaceContainerHigh,
                                child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget helpers ───────────────────────────────────────────────────

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _infoCard(BuildContext context, List<Widget> rows) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: rows
            .asMap()
            .entries
            .map((e) => Column(children: [
                  e.value,
                  if (e.key < rows.length - 1)
                    Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: cs.outlineVariant.withValues(alpha: 0.4)),
                ]))
            .toList(),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? valueNote,
    bool highlight = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                    color: highlight ? AppColors.primary : cs.onSurface,
                  ),
                ),
                if (valueNote != null)
                  Text(valueNote,
                      style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ── Format helpers ────────────────────────────────────────────────────

  String _fmtTanggal(String raw) {
    // "2026-06-15" → "15 Juni 2026"
    try {
      final dt = DateTime.parse(raw);
      const bulan = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String _fmtRupiah(double v) {
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)}jt/kg';
    if (v >= 1000) return 'Rp ${(v / 1000).toStringAsFixed(1)}rb/kg';
    return 'Rp ${v.toStringAsFixed(0)}/kg';
  }

  String _fmtRupiahLong(double v) {
    if (v >= 1000000000) {
      return 'Rp ${(v / 1000000000).toStringAsFixed(2)} M';
    }
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(2)} jt';
    // Di bawah 1 juta: tampilkan nilai penuh dengan pemisah titik ribuan
    // agar tidak ada pembulatan (misal 7.600 bukan dibulatkan jadi 8 rb)
    final formatted = v.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}
