import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voucho_app/providers/app_state.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:voucho_app/data/models/transaction_model.dart'; 

class ContactDetailView extends StatelessWidget {
  final String contactName;
  const ContactDetailView({super.key, required this.contactName});

  // --- FONCTION DE PARTAGE WHATSAPP ---
  void _partagerRecu(TransactionModel t, String monNom, AppState state) {
    String message = """
📜 *REÇU VOUCHO - PREUVE* 📜
----------------------------------
👤 *Client:* ${t.personName}
💰 *Montant Initial:* ${state.formatAmount(t.amount)}
📉 *RESTE À PAYER:* ${state.formatAmount(t.remainingAmount)}
📅 *Date:* ${t.date.day}/${t.date.month}/${t.date.year}
----------------------------------
✅ *Validé sur l'App Voucho.*
Propriétaire: $monNom
    """;
    
    Share.share(message);
  }

  // --- DIALOGUE POUR PAYER ---
  void _showPayDialog(BuildContext context, AppState state, String id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3339),
        title: const Text("Encaisser / Payer", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller, 
          keyboardType: TextInputType.number, 
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Montant reçu", 
            labelStyle: TextStyle(color: Colors.cyanAccent),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          )
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // CORRECTION : On utilise addPayment défini dans AppState
                state.addPayment(id, double.parse(controller.text));
                Navigator.pop(context);
              }
            }, 
            child: const Text("Valider")
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    // CORRECTION : Utilisation de activeTransactions au lieu de transactionsHistory
    final history = state.activeTransactions.where((t) => t.personName == contactName).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: Text("Historique : $contactName", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 40, 
            backgroundColor: Colors.cyan, 
            child: Icon(Icons.person, size: 40, color: Colors.white)
          ),
          const SizedBox(height: 10),
          Text(contactName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24, height: 40),
          
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, i) {
                final t = history[i];
                // CORRECTION : Vérification du statut terminé
                bool isCompleted = t.remainingAmount <= 0;

                return Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ExpansionTile(
                    iconColor: Colors.cyan,
                    collapsedIconColor: Colors.white,
                    title: Text(state.formatAmount(t.amount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("Reste: ${state.formatAmount(t.remainingAmount)}", 
                         style: TextStyle(color: isCompleted ? Colors.green : Colors.redAccent)),
                    trailing: IconButton(
                      icon: const Icon(Icons.share, color: Colors.cyanAccent),
                      onPressed: () => _partagerRecu(t, state.currentUserName, state),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            if (t.note.isNotEmpty) ...[
                              Text("Note: ${t.note}", style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 15),
                            ],
                            isCompleted 
                              ? const Text("✅ TRANSACTION TERMINÉE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                                  onPressed: () => _showPayDialog(context, state, t.id),
                                  child: const Text("ENCAISSER UN PAIEMENT", style: TextStyle(color: Colors.black)),
                                ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}