// lib/screens/alert_screen.dart
// Hanya untuk petugas.
// Fix: konfigurasi → pakai GET/PUT /api/alert/konfigurasi (bukan stok/{id})
//      tampilan kartu stok sesuai web admin (beras/gabah hard-coded dari API)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/app_colors.dart';
import '../models/alert_model.dart';
import '../models/gudang_model.dart';
import '../services/alert_service.dart';
import '../services/stok_service.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final AlertService _alertService = AlertService();
  final StokService  _stokService  = StokService();

  List<AlertModel> _alerts   = [];
  List<StokModel>  _stokList = [];
  bool _loadingAlerts = true;
  bool _loadingStok   = true;
  String? _errorAlerts;

  // Konfigurasi batas minimum (dari alert_configurations via API)
  double _batasMinBeras = 400;
  double _batasMinGabah = 1000;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadAlerts(), _loadStok(), _loadKonfigurasi()]);
  }

  Future<void> _loadAlerts() async {
    setState(() { _loadingAlerts = true; _errorAlerts = null; });
    try {
      final list = await _alertService.getAll();
      if (mounted) setState(() { _alerts = list; _loadingAlerts = false; });
    } catch (e) {
      if (mounted) setState(() { _errorAlerts = e.toString(); _loadingAlerts = false; });
    }
  }

  Future<void> _loadStok() async {
    setState(() => _loadingStok = true);
    try {
      final list = await _stokService.getMonitoring();
      if (mounted) setState(() { _stokList = list; _loadingStok = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingStok = false);
    }
  }

  Future<void> _loadKonfigurasi() async {
    try {
      final cfg = await _alertService.getKonfigurasi();
      if (mounted) {
        setState(() {
          _batasMinBeras = cfg['batas_min_beras'] ?? 400;
          _batasMinGabah = cfg['batas_min_gabah'] ?? 1000;
        });
      }
    } catch (_) {
      // gunakan default
    }
  }

  // ── Update status alert ──────────────────────────────────────────────
  Future<void> _markAsHandled(int alertId, String newStatus) async {
    try {
      await _alertService.update(alertId, {'status': newStatus});
      _loadAlerts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Status diupdate ke $newStatus'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  // ── Dialog Konfigurasi Batas Minimum ─────────────────────────────────
  void _showKonfigurasiDialog() {
    final berasCtrl = TextEditingController(
      text: _batasMinBeras.toStringAsFixed(0),
    );
    final gabahCtrl = TextEditingController(
      text: _batasMinGabah.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              Row(children: [
                const Expanded(
                  child: Text('Konfigurasi Batas Minimum Alert',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      )),
                ),
                InkWell(
                  onTap: () => Navigator.pop(ctx),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 20,
                        color: AppColors.onSurfaceVariant),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // Info banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFF57C00), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nilai akan disimpan ke konfigurasi sistem dan berlaku untuk semua stok.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF795548)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Input fields
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Batas Minimum Beras (kg)',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          )),
                      const SizedBox(height: 6),
                      TextField(
                        controller: berasCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '400',
                          helperText: 'Default: 400 kg',
                          helperStyle: const TextStyle(fontSize: 11),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
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
                      const Text('Batas Minimum Gabah (kg)',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          )),
                      const SizedBox(height: 6),
                      TextField(
                        controller: gabahCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '1000',
                          helperText: 'Default: 1000 kg',
                          helperStyle: const TextStyle(fontSize: 11),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // Tombol
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                _SaveButton(
                  berasCtrl: berasCtrl,
                  gabahCtrl: gabahCtrl,
                  onSave: (newBeras, newGabah) async {
                    // Simpan ke /api/alert/konfigurasi (bukan stok/{id})
                    await _alertService.saveKonfigurasi(
                      batasMinBeras: newBeras,
                      batasMinGabah: newGabah,
                    );
                    // Tutup dialog
                    if (ctx.mounted) Navigator.pop(ctx);
                    // Update state lokal & reload data
                    if (mounted) {
                      setState(() {
                        _batasMinBeras = newBeras;
                        _batasMinGabah = newGabah;
                      });
                      await _loadStok();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Konfigurasi berhasil disimpan'),
                          backgroundColor: AppColors.primary,
                        ));
                      }
                    }
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers status ────────────────────────────────────────────────────
  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'aktif':   return AppColors.error;
      case 'proses':  return const Color(0xFFF57C00);
      case 'selesai': return AppColors.primary;
      default:        return AppColors.onSurfaceVariant;
    }
  }
  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'aktif':   return 'Alert Aktif';
      case 'proses':  return 'Dalam Penanganan';
      case 'selesai': return 'Sudah Ditangani';
      default:        return s;
    }
  }
  IconData _statusIcon(String s) {
    switch (s.toLowerCase()) {
      case 'aktif':   return Icons.warning_rounded;
      case 'proses':  return Icons.hourglass_bottom_rounded;
      case 'selesai': return Icons.check_circle_rounded;
      default:        return Icons.info_rounded;
    }
  }

  // Sesuai web: merah jika < batas, kuning jika < 1.5x batas, hijau jika aman
  Color _stokColor(double stok, double batas) {
    if (stok >= batas) return AppColors.primary;
    if (stok >= batas * 0.5) return const Color(0xFFF57C00);
    return AppColors.error;
  }
  String _stokLabel(double stok, double batas) {
    if (stok >= batas) return 'Aman';
    if (stok >= batas * 0.5) return 'Rendah';
    return 'Kritis';
  }

  // ── Build kartu stok (tampilan sesuai web) ────────────────────────────
  Widget _buildStokCards() {
    if (_loadingStok) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Buat kartu dari stokList berdasarkan komoditas
    // Selalu pastikan Beras & Gabah keduanya tampil
    final Map<String, Map<String, dynamic>> cardMap = {
      'Beras': {
        'nama': 'Beras',
        'stok': 0.0,
        'batas': _batasMinBeras,
        'kapasitas': 10000.0, // default kapasitas beras sesuai web admin
        'ada': false,
      },
      'Gabah': {
        'nama': 'Gabah',
        'stok': 0.0,
        'batas': _batasMinGabah,
        'kapasitas': 5000.0, // default kapasitas gabah sesuai web admin
        'ada': false,
      },
    };

    for (final s in _stokList) {
      final komoditas = s.komoditas ?? s.gudang?.namaGudang ?? '';
      final isGabah = komoditas.toLowerCase().contains('gabah');
      final isBeras = komoditas.toLowerCase().contains('beras');
      final key = isGabah ? 'Gabah' : (isBeras ? 'Beras' : null);
      if (key != null) {
        final cap = s.gudang?.kapasitas;
        cardMap[key] = {
          'nama': key,
          'stok': s.jumlahStok,
          'batas': key == 'Gabah' ? _batasMinGabah : _batasMinBeras,
          'kapasitas': (cap != null && cap > 0) ? cap : cardMap[key]!['kapasitas'],
          'ada': true,
        };
      }
    }

    final List<Map<String, dynamic>> cards = [cardMap['Beras']!, cardMap['Gabah']!];

    return Row(
      children: List.generate(cards.length, (i) {
        final c       = cards[i];
        final nama    = c['nama'] as String;
        final stok    = c['stok'] as double;
        final batas   = c['batas'] as double;
        final cap     = c['kapasitas'] as double;
        final color   = _stokColor(stok, batas);
        final label   = _stokLabel(stok, batas);
        final persen  = cap > 0 ? (stok / cap * 100).clamp(0.0, 100.0) : 0.0;
        final sisa    = cap - stok;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < cards.length - 1 ? 10 : 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama komoditas
                Row(children: [
                  SvgPicture.network(
                    'https://raw.githubusercontent.com/NoahMikhailovna/foto/c45c72f9adca95001eefebd49d7581e89d0de508/padi_logo_fitted.svg',
                    width: 11,
                    height: 11,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(nama,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 10),
                // Stok saat ini + badge status — sesuai web
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        '${_fmtNum(stok)} kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Batas min & Kapasitas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Batas minimum',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant)),
                        Text('${_fmtNum(batas)} kg',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            )),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Kapasitas',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant)),
                        Text(cap > 0 ? '${_fmtNum(cap)} kg' : '-',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            )),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: persen / 100,
                    backgroundColor: AppColors.outlineVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                // Persen & sisa — sesuai web
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${persen.toStringAsFixed(0)}% dari kapasitas',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.onSurfaceVariant),
                    ),
                    Text(
                      cap > 0 ? '${_fmtNum(sisa.clamp(0, double.infinity))} kg tersisa' : '',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _fmtNum(double v) {
    final n = NumberFormat('#,##0', 'id_ID');
    return n.format(v);
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final aktifCount   = _alerts.where((a) => a.isAktif).length;
    final prosesCount  = _alerts.where((a) => a.isProses).length;
    final selesaiCount = _alerts.where((a) => a.isSelesai).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              const Text('Alert Stok',
                  style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w800,
                    color: AppColors.onSurface, letterSpacing: -0.5,
                  )),
              const SizedBox(height: 4),
              const Text(
                'Notifikasi otomatis saat stok mendekati batas minimum',
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // ── Konfigurasi Batas Minimum ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Konfigurasi Batas Minimum',
                                style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                )),
                            SizedBox(height: 2),
                            Text(
                              'Sistem akan memicu alert jika stok berada di bawah batas minimum',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _showKonfigurasiDialog,
                        icon: const Icon(Icons.settings_outlined, size: 14),
                        label: const Text('Ubah', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildStokCards(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Ringkasan Status Alert ────────────────────────────────
              const Text('Ringkasan Status Alert',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  )),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _buildStatusCard(
                    title: 'Alert Aktif', count: aktifCount,
                    color: AppColors.error, icon: Icons.warning_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusCard(
                    title: 'Dalam Penanganan', count: prosesCount,
                    color: const Color(0xFFF57C00),
                    icon: Icons.hourglass_bottom_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusCard(
                    title: 'Sudah Ditangani', count: selesaiCount,
                    color: AppColors.primary,
                    icon: Icons.check_circle_rounded)),
              ]),
              const SizedBox(height: 28),

              // ── Riwayat Alert ─────────────────────────────────────────
              const Text('Riwayat Alert',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  )),
              const SizedBox(height: 4),
              const Text('Semua notifikasi sistem, terbaru di atas',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 16),

              if (_loadingAlerts)
                const Center(child: CircularProgressIndicator(
                    color: AppColors.primary))
              else if (_errorAlerts != null)
                _buildError()
              else if (_alerts.isEmpty)
                _buildEmpty()
              else
                Column(children: _alerts.map(_buildAlertItem).toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title, required int count,
    required Color color, required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(count.toString(),
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(AlertModel alert) {
    final color = _statusColor(alert.status);
    final label = _statusLabel(alert.status);
    final icon  = _statusIcon(alert.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.03),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.komoditas,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.onSurface)),
                    const SizedBox(height: 4),
                    Wrap(spacing: 8, children: [
                      Text('Stok: ${alert.stokSaatIni.toStringAsFixed(0)} kg',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.onSurfaceVariant)),
                      Text('Batas Min: ${alert.batasMinimum.toStringAsFixed(0)} kg',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.onSurfaceVariant)),
                    ]),
                    const SizedBox(height: 2),
                    Text(
                      alert.createdAt != null
                          ? DateFormat('dd MMM yyyy HH:mm')
                              .format(DateTime.parse(alert.createdAt!))
                          : 'Tanggal tidak tersedia',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: color)),
                  ),
                  if (alert.handler != null) ...[
                    const SizedBox(height: 8),
                    Text('By: ${alert.handler!.name}',
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.right),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (alert.isAktif)
            _actionBtn('Tandai Ditangani', const Color(0xFFF57C00),
                () => _markAsHandled(alert.id, 'proses'))
          else if (alert.isProses)
            _actionBtn('Tandai Selesai', AppColors.primary,
                () => _markAsHandled(alert.id, 'selesai'))
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('✓ Sudah Ditangani',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                  textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600, fontSize: 11)),
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 48,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text('Belum ada alert',
                style: TextStyle(
                    fontSize: 14, color: AppColors.onSurfaceVariant)),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48,
                color: AppColors.error.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(_errorAlerts ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAlerts,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
}

// ── Widget terpisah agar StatefulBuilder tidak conflict dengan context dialog ──
class _SaveButton extends StatefulWidget {
  final TextEditingController berasCtrl;
  final TextEditingController gabahCtrl;
  final Future<void> Function(double beras, double gabah) onSave;

  const _SaveButton({
    required this.berasCtrl,
    required this.gabahCtrl,
    required this.onSave,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _saving ? null : _handleSave,
      icon: _saving
          ? const SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.save_outlined, size: 16),
      label: Text(_saving ? 'Menyimpan...' : 'Simpan Konfigurasi'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleSave() async {
    final newBeras = double.tryParse(widget.berasCtrl.text.trim());
    final newGabah = double.tryParse(widget.gabahCtrl.text.trim());

    if (newBeras == null || newBeras < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai batas beras tidak valid'),
            backgroundColor: AppColors.error));
      return;
    }
    if (newGabah == null || newGabah < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai batas gabah tidak valid'),
            backgroundColor: AppColors.error));
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSave(newBeras, newGabah);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }
}
