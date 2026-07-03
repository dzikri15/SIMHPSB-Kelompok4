// lib/petani_shell.dart
// Shell navigasi khusus untuk user dengan role 'petani'

import 'package:flutter/material.dart';
import 'screens/petani/petani_beranda_screen.dart';
import 'screens/petani/petani_profil_screen.dart';

class PetaniShell extends StatefulWidget {
  const PetaniShell({super.key});

  @override
  State<PetaniShell> createState() => _PetaniShellState();
}

class _PetaniShellState extends State<PetaniShell> {
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PetaniProfilScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PetaniBerandaScreen(
        onProfileTap: _navigateToProfile,
      ),
    );
  }
}
