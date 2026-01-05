import 'package:flutter/material.dart';
import 'package:voucho/widgets/transaction_card.dart';


class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique complet")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Remplacer par la longueur de la liste Firebase
        itemBuilder: (context, index) {
          return const TransactionCard(
            name: "Contact Inconnu",
            amount: 2500,
            isDebt: false,
            date: "12 Janv 2024",
          );
        },
      ),
    );
  }
}