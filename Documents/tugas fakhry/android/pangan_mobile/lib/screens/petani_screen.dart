// lib/screens/petani_screen.dart
// Terhubung penuh ke Laravel API (GET/POST/PUT/DELETE)

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_top_bar.dart';
import '../models/petani_model.dart';
import '../services/petani_service.dart';
import '../services/api_service.dart';

class PetaniScreen extends StatefulWidget {
  const PetaniScreen({super.key});

  @override
  State<PetaniScreen> createState() => _PetaniScreenState();
}

class _PetaniScreenState extends State<PetaniScreen> {
  final PetaniService _service = PetaniService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<PetaniModel> _petaniList = [];
  List<PetaniModel> _filtered = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _service.getAll();
      if (mounted) {
        setState(() {
          _petaniList = list;
          _filtered = list;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _petaniList
          : _petaniList.where((p) =>
              p.nama.toLowerCase().contains(q) ||
              (p.alamat?.toLowerCase().contains(q) ?? false) ||
              (p.komoditas?.toLowerCase().contains(q) ?? false)).toList();
    });
  }

  // ── Dialog tambah/edit ────────────────────────────────────────────────

  void _showFormDialog({PetaniModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.nama ?? '');
    final nikCtrl = TextEditingController(text: existing?.nik ?? '');
    final telpCtrl = TextEditingController(text: existing?.noHp ?? existing?.telepon ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final alamatCtrl = TextEditingController(text: existing?.alamat ?? '');
    final catatanCtrl = TextEditingController(text: existing?.catatan ?? '');
    String selectedStatus = existing?.status ?? 'aktif';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    existing == null ? 'Tambah Data Petani' : 'Edit Data Petani',
                    style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 20),
                  _field('Nama Lengkap *', nameCtrl, 'Nama petani'),
                  const SizedBox(height: 14),
                  _field('NIK', nikCtrl, '16 digit NIK'),
                  const SizedBox(height: 14),
                  _field('No. HP', telpCtrl, '+62 8xx xxxx xxxx'),
                  const SizedBox(height: 14),
                  _field('Email', emailCtrl, 'email@example.com',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _field('Alamat *', alamatCtrl, 'Alamat lengkap', maxLines: 3),
                  const SizedBox(height: 14),
                  _field('Catatan', catatanCtrl, 'Opsional', maxLines: 2),
                  const SizedBox(height: 14),
                  // Status Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: AppColors.onSurface)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        items: ['aktif', 'nonaktif']
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e[0].toUpperCase() + e.substring(1))))
                            .toList(),
                        onChanged: (val) =>
                            setLocal(() => selectedStatus = val ?? selectedStatus),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal',
                            style: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (nameCtrl.text.trim().isEmpty ||
                                    alamatCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Nama dan Alamat wajib diisi')),
                                  );
                                  return;
                                }
                                setLocal(() => isSaving = true);
                                final body = {
                                  'nama': nameCtrl.text.trim(),
                                  'nik': nikCtrl.text.trim(),
                                  'no_hp': telpCtrl.text.trim(),
                                  'email': emailCtrl.text.trim().isEmpty
                                      ? null
                                      : emailCtrl.text.trim(),
                                  'alamat': alamatCtrl.text.trim(),
                                  'catatan': catatanCtrl.text.trim(),
                                  'status': selectedStatus,
                                };
                                try {
                                  if (existing == null) {
                                    await _service.create(body);
                                  } else {
                                    await _service.update(existing.id, body);
                                  }
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  _loadData();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(existing == null
                                          ? 'Petani berhasil ditambahkan'
                                          : 'Data petani berhasil diperbarui'),
                                      backgroundColor: AppColors.primary,
                                    ));
                                  }
                                } on ApiException catch (e) {
                                  setLocal(() => isSaving = false);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('Error: ${e.message}'),
                                      backgroundColor: AppColors.error,
                                    ));
                                  }
                                }
                              },
                        icon: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check),
                        label: Text(existing == null ? 'Simpan' : 'Update'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deletePetani(PetaniModel petani) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Petani?'),
        content: Text('Data "${petani.nama}" akan dihapus permanen.'),
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
      await _service.delete(petani.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Data petani berhasil dihapus'),
          backgroundColor: AppColors.error,
        ));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')));
      }
    }
  }

  void _showDetail(PetaniModel p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _DetailPetaniPage(
          petani: p,
          onEdit: () {
            Navigator.pop(context);
            _showFormDialog(existing: p);
          },
          onDelete: () {
            Navigator.pop(context);
            _deletePetani(p);
          },
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Data Petani',
              style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.w800,
                color: AppColors.onSurface, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kelola informasi demografi dan lokasi lahan petani binaan.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // Tambah Petani
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showFormDialog(),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Tambah Petani',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Cari nama petani, alamat, atau komoditas...',
                  hintStyle: TextStyle(color: AppColors.outline, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: AppColors.outline, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return const Center(
        child: Text('Tidak ada data petani.',
            style: TextStyle(color: AppColors.onSurfaceVariant)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
        itemBuilder: (_, i) {
          final p = _filtered[i];
          return _petaniTile(p);
        },
      ),
    );
  }

  Widget _petaniTile(PetaniModel p) {
    final isAktif = p.status == 'aktif';
    return GestureDetector(
      onTap: () => _showDetail(p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: isAktif
                    ? AppColors.primaryContainer
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.agriculture,
                  color: isAktif ? AppColors.primary : AppColors.onSurfaceVariant,
                  size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nama,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: AppColors.onSurface)),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        p.alamat ?? '-',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.onSurfaceVariant),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isAktif
                    ? const Color(0xFFDCFCE7)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isAktif ? 'Aktif' : 'Nonaktif',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: isAktif
                        ? const Color(0xFF166534)
                        : AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showFormDialog(existing: p),
              child: const Icon(Icons.edit_outlined,
                  color: AppColors.outline, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: AppColors.onSurface)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.outline, fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

// ── Detail Page ───────────────────────────────────────────────────────────

class _DetailPetaniPage extends StatelessWidget {
  final PetaniModel petani;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DetailPetaniPage({
    required this.petani,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAktif = petani.status == 'aktif';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: AppColors.onSurface),
        ),
        title: const Text('Detail Petani',
            style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.agriculture,
                      color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(petani.nama,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800,
                              color: AppColors.onSurface)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAktif
                              ? const Color(0xFFDCFCE7)
                              : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isAktif ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: isAktif
                                  ? const Color(0xFF166534)
                                  : AppColors.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            _section('Informasi Pribadi', [
              _row('Nama', petani.nama),
              _row('NIK', petani.nik ?? '-'),
              _row('No. HP', petani.noHp ?? petani.telepon ?? '-'),
              _row('Email', petani.email ?? '-'),
              _row('Tanggal Lahir', petani.tanggalLahir ?? '-'),
              _row('Alamat', petani.alamat ?? '-'),
            ]),
            const SizedBox(height: 20),

            if (petani.lahan.isNotEmpty) ...[
              _section('Data Lahan (${petani.lahan.length})', [
                for (final l in petani.lahan) ...[
                  _row('Nama Lahan', l.namaLahan ?? 'Lahan ${l.id}'),
                  _row('Luas', l.luas != null ? '${l.luas} m²' : '-'),
                  _row('Komoditas', l.komoditas ?? '-'),
                  _row('Status Lahan', l.status ?? '-'),
                  if (petani.lahan.indexOf(l) < petani.lahan.length - 1)
                    const Divider(),
                ],
              ]),
              const SizedBox(height: 20),
            ],

            if (petani.catatan != null && petani.catatan!.isNotEmpty) ...[
              _section('Catatan', [_row('', petani.catatan!)]),
              const SizedBox(height: 20),
            ],

            // Actions
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Kembali'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.outline,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.onSurface)),
      const SizedBox(height: 12),
      ...children,
    ]);
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        if (label.isNotEmpty)
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant)),
          ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: AppColors.onSurface),
              maxLines: 3, overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}
