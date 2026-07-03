// lib/screens/petani/petani_profil_screen.dart
// Halaman profil petani — menampilkan semua data diri dari tabel petani
 
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_colors.dart';
import '../../models/petani_model.dart';
import '../../services/petani_profile_service.dart';

import '../../widgets/app_top_bar.dart';

 
class PetaniProfilScreen extends StatefulWidget {
  const PetaniProfilScreen({super.key});
 
  @override
  State<PetaniProfilScreen> createState() => _PetaniProfilScreenState();
}
 
class _PetaniProfilScreenState extends State<PetaniProfilScreen> {
  final PetaniProfileService _svc = PetaniProfileService();
 
  PetaniModel? _petani;
  bool         _loading = true;
  String?      _error;
 
  @override
  void initState() {
    super.initState();
    _load();
  }
 
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _svc.getProfile();
      if (mounted) setState(() { _petani = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }


 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppTopBar(showAlert: false, showBack: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 24),
                      _buildSectionIdentitas(),
                      const SizedBox(height: 16),
                      _buildSectionKontak(),
                      const SizedBox(height: 16),
                      _buildSectionLahan(),
                      if (_petani!.catatan != null &&
                          _petani!.catatan!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSectionCatatan(),
                      ],
                    ],
                  ),
                ),
    );
  }
 
  // ── Avatar & Nama ──────────────────────────────────────────────────────
  Widget _buildAvatar() {
    final p = _petani!;
    final isAktif = p.isAktif;
    return Column(
      children: [
        // Header banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.brandMedium, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Text(
                'Profil Saya',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p.nama,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        // Avatar overlapping
        Transform.translate(
          offset: const Offset(0, -48),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.network(
                    'https://raw.githubusercontent.com/NoahMikhailovna/foto/c45c72f9adca95001eefebd49d7581e89d0de508/padi_logo_fitted.svg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isAktif ? AppColors.accentGreenLight : AppColors.accentOrangeLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAktif
                        ? AppColors.accentGreen
                        : AppColors.accentOrange,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAktif ? Icons.check_circle : Icons.pause_circle,
                      size: 13,
                      color: isAktif
                          ? AppColors.accentGreen
                          : AppColors.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAktif ? 'Aktif' : 'Non-aktif',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isAktif
                            ? AppColors.accentGreen
                            : AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Kompensasi transform offset (Transform.translate sudah handle overlap)
        const SizedBox(height: 0),
      ],
    );
  }
 
  // ── Section: Identitas ─────────────────────────────────────────────────
  Widget _buildSectionIdentitas() {
    final p = _petani!;
    return _section(
      title: 'Identitas',
      icon: Icons.badge_outlined,
      items: [
        _item('Nama Lengkap', p.nama, Icons.person_outline),
        if (p.alamat != null && p.alamat!.isNotEmpty)
          _item('Alamat', p.alamat!, Icons.location_on_outlined),
      ],
    );
  }
 
  // ── Section: Kontak ────────────────────────────────────────────────────
  Widget _buildSectionKontak() {
    final p = _petani!;
    final kontakItems = <Widget>[];
    if (p.noHp != null && p.noHp!.isNotEmpty) {
      kontakItems.add(_item('No. HP', p.noHp!, Icons.phone_outlined));
    }
    if (p.telepon != null && p.telepon!.isNotEmpty) {
      kontakItems.add(_item('Telepon', p.telepon!, Icons.call_outlined));
    }
    kontakItems.add(_item(
      'Email',
      (p.email != null && p.email!.isNotEmpty) ? p.email! : '-',
      Icons.email_outlined,
    ));
 
    return _section(
      title: 'Kontak',
      icon: Icons.contacts_outlined,
      items: kontakItems,
    );
  }
 
  // ── Section: Data Lahan ────────────────────────────────────────────────
  Widget _buildSectionLahan() {
    final p = _petani!;
    return _section(
      title: 'Data Lahan & Komoditas',
      icon: Icons.terrain_outlined,
      items: [
        if (p.luasLahan != null)
          _item(
            'Luas Lahan',
            '${p.luasLahan!.toStringAsFixed(0)} m²',
            Icons.square_foot_outlined,
          ),
        if (p.komoditas != null && p.komoditas!.isNotEmpty)
          _item('Komoditas Utama', _labelKomoditas(p.komoditas!),
              Icons.grass_outlined),
        _item(
          'Jumlah Lahan',
          '${p.lahan.length} petak',
          Icons.landscape_outlined,
        ),
        // Daftar nama lahan
        if (p.lahan.isNotEmpty)
          ...p.lahan.map(
            (l) => _item(
              l.namaLahan ?? '-',
              '${l.luas?.toStringAsFixed(0) ?? '-'} m²${l.lokasi != null ? ' · ${l.lokasi}' : ''}',
              Icons.pin_drop_outlined,
              isSubItem: true,
            ),
          ),
      ],
    );
  }
 
  // ── Section: Catatan ──────────────────────────────────────────────────
  Widget _buildSectionCatatan() {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Catatan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _petani!.catatan!,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }


 
  // ── Builder helpers ────────────────────────────────────────────────────
  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.4),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Items
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                e.value,
                if (!isLast)
                  Divider(height: 1, indent: 52, color: Theme.of(context).colorScheme.outline),
              ],
            );
          }),
        ],
      ),
    );
  }
 
  Widget _item(
    String label,
    String value,
    IconData icon, {
    bool isSubItem = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isSubItem ? 8 : 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSubItem
                  ? AppColors.surfaceContainerHighest
                  : AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isSubItem ? AppColors.outline : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  String _labelKomoditas(String k) {
    const map = {
      'padi': 'Padi',
      'jagung': 'Jagung',
      'padi_jagung': 'Padi & Jagung',
    };
    return map[k.toLowerCase()] ?? k;
  }
 
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}