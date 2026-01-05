import 'package:flutter/material.dart';
import 'package:voucho/app/components/space.dart';
import 'package:voucho/utils/colors.dart';
import 'package:voucho/app/components/button_components.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mon Profil"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Section Avatar et Nom
            const Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  Space.h20,
                  Text(
                    "Utilisateur Voucho",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  Text(
                    "membre@voucho.com",
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            Space.h30,

            // Section Statistiques simples
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ProfileStat(label: "Dettes", count: "12"),
                  _ProfileStat(label: "Prêts", count: "5"),
                  _ProfileStat(label: "Réglés", count: "28"),
                ],
              ),
            ),
            Space.h30,

            // Menu d'options
            _buildProfileMenu(Icons.settings_outlined, "Paramètres"),
            _buildProfileMenu(Icons.help_outline, "Aide & Support"),
            _buildProfileMenu(Icons.info_outline, "À propos de Voucho"),
            
            Space.h30,
            
            // Bouton de déconnexion
            PrimaryButton(
              label: "Se déconnecter", 
              color: AppColors.danger,
              onPressed: () {
                // Ici tu appelleras ton AuthService.signOut()
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
      onTap: () {},
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String count;
  const _ProfileStat({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
      ],
    );
  }
}