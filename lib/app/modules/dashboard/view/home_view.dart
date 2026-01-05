import 'package:flutter/material.dart';
import 'package:voucho/app/components/space.dart';
import 'package:voucho/app/components/text_components.dart';
import 'package:voucho/utils/colors.dart';
import '../../../../widgets/transaction_card.dart'; // On va le créer juste après

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Mon Tableau de Bord", style: TextComponents.title.copyWith(fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
            onPressed: () {},
          ),
          const CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
          Space.w20,
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Space.h20,
            _buildSummaryCards(),
            Space.h30,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transactions récentes", style: TextComponents.title.copyWith(fontSize: 18)),
                TextButton(onPressed: () {}, child: const Text("Voir tout")),
              ],
            ),
            Space.h10,
            // Liste fictive pour le test de l'UI
            const TransactionCard(name: "Jean Marc", amount: 5000, isDebt: true, date: "Aujourd'hui"),
            const TransactionCard(name: "Sarah K.", amount: 12500, isDebt: false, date: "Hier"),
            const TransactionCard(name: "Boulangerie", amount: 1200, isDebt: true, date: "24 Déc"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // Navigation vers l'ajout de transaction
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // Widget interne pour les cartes de résumé
  Widget _buildSummaryCards() {
    return Row(
      children: [
        _summaryItem("À payer", "18.500 FC", AppColors.danger),
        Space.w10,
        _summaryItem("À percevoir", "45.000 FC", AppColors.accent),
      ],
    );
  }

  Widget _summaryItem(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextComponents.subtitle),
            Space.h10,
            Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}