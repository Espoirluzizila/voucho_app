import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voucho/providers/app_state.dart';
import 'package:voucho/data/models/transaction_model.dart';

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
        title: const Text("Remboursement", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _paymentController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Montant payé (\$)",
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00ACC1)),
            onPressed: () {
              final amount = double.tryParse(_paymentController.text) ?? 0;
              if (amount > 0 && amount <= t.remainingAmount) {
                state.addPayment(t.id, amount);
                _paymentController.clear();
                Navigator.pop(context);
                Navigator.pop(context); // Retour à l'accueil pour voir la mise à jour
              }
            },
            child: const Text("Confirmer", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupération sécurisée de la transaction
    final t = ModalRoute.of(context)!.settings.arguments as TransactionModel;
    final state = Provider.of<AppState>(context);

    return Scaffold(
      // On garde le même fond sombre que la Home
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        title: const Text("Détails du compte", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- CARTE DE RÉSUMÉ (Style Dégradé comme la Home) ---
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00ACC1), Color(0xFF007A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      t.type == 'loan' ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(t.personName, 
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(
                    t.type == 'loan' ? "doit vous rembourser" : "vous devez rembourser", 
                    style: const TextStyle(color: Colors.white70)
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoColumn("Total Initial", state.formatAmount(t.amount)),
                      _infoColumn("Reste à percevoir", state.formatAmount(t.remainingAmount), color: const Color(0xFF40FFFF)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),
            _sectionTitle("Actions rapides"),
            const SizedBox(height: 15),

            // --- BOUTONS D'ACTION ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: t.remainingAmount > 0 ? () => _showPaymentDialog(context, state, t) : null,
                    icon: const Icon(Icons.add_moderator, color: Colors.white),
                    label: const Text("Rembourser", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () async {
                      // Correction de l'erreur : Suppression directe Firebase
                      await FirebaseFirestore.instance.collection('transactions').doc(t.id).delete();
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: const Text("Supprimer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 35),
            _sectionTitle("Historique de l'opération"),
            const SizedBox(height: 10),
            
            // --- LISTE DE L'HISTORIQUE ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: const Icon(Icons.edit_calendar, color: Colors.cyanAccent),
                title: const Text("Date de début", style: TextStyle(color: Colors.white)),
                subtitle: Text(DateFormat('dd MMMM yyyy').format(t.date), style: const TextStyle(color: Colors.white54)),
                trailing: Text("+ ${state.formatAmount(t.amount)}", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _infoColumn(String label, String value, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}