import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voucho/data/models/transaction_model.dart';

class TransactionDetailsView extends StatelessWidget {
  const TransactionDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ModalRoute.of(context)!.settings.arguments as TransactionModel;

    return Scaffold(
      appBar: AppBar(title: const Text("Détails")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(t.personName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Total: ${t.amount} \$", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("RESTE À PAYER :", style: const TextStyle(color: Colors.red)),
            Text("${t.remainingAmount} \$", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            
            const Spacer(),
            
            // BOUTON WHATSAPP
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text("PARTAGER SUR WHATSAPP"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  String message = "Recu Voucho pour ${t.personName}\n"
                                   "Montant: ${t.amount} \$\n"
                                   "Reste: ${t.remainingAmount} \$\n"
                                   "Veuillez solder votre dette rapidement.";
                  Share.share(message); // Cela ouvre le sélecteur d'appli dont WhatsApp
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}