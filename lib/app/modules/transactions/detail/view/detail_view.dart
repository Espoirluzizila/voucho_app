import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:voucho_app/providers/app_state.dart';
import 'package:voucho_app/data/models/transaction_model.dart';
import 'package:voucho_app/utils/colors.dart';

class DetailsView extends StatefulWidget {
  const DetailsView({super.key});

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  final TextEditingController _paymentController = TextEditingController();

  // --- Dialogue pour encaisser un paiement ---
  void _showPaymentDialog(BuildContext context, AppState state, TransactionModel t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3339),
        title: Text("Remboursement (\$)", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: _paymentController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Montant payé",
            labelStyle: TextStyle(color: Colors.cyanAccent),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_paymentController.text) ?? 0;
              if (amount > 0 && amount <= t.remainingAmount) {
                state.addPayment(t.id, amount); // On met à jour dans Firebase via AppState
                _paymentController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupération de la transaction passée en argument
    final t = ModalRoute.of(context)!.settings.arguments as TransactionModel;
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Détails du compte"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- CARTE DE RÉSUMÉ ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: t.type == 'loan' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    child: Icon(
                      t.type == 'loan' ? Icons.arrow_downward : Icons.arrow_upward,
                      color: t.type == 'loan' ? Colors.green : Colors.red,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(t.personName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(t.type == 'loan' ? "doit vous rembourser" : "vous devez rembourser", style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoColumn("Total", state.formatAmount(t.amount)),
                      _infoColumn("Reste", state.formatAmount(t.remainingAmount), color: Colors.cyanAccent),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Actions", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),

            // --- BOUTONS D'ACTION ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: t.remainingAmount > 0 ? () => _showPaymentDialog(context, state, t) : null,
                    icon: const Icon(Icons.add_card),
                    label: const Text("Rembourser"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () {
                      state.deleteTransaction(t.id);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Supprimer"),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Historique", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            // --- LISTE DES PAIEMENTS (Historique) ---
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.event_note, color: Colors.white24),
                    title: const Text("Création de la dette", style: TextStyle(color: Colors.white)),
                    subtitle: Text(DateFormat('dd MMMM yyyy').format(t.date), style: const TextStyle(color: Colors.white54)),
                    trailing: Text("+ ${state.formatAmount(t.amount)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  // Ici tu pourras boucler sur une sous-collection de paiements si tu l'ajoutes plus tard
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}