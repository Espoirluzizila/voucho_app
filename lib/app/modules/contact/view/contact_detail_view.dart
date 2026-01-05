import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voucho/providers/app_state.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:voucho/data/models/transaction_model.dart'; 

class ContactDetailView extends StatelessWidget {
  final String contactName;
  const ContactDetailView({super.key, required this.contactName});

  // --- FONCTION DE PARTAGE ---
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

  // --- DIALOGUE POUR ENCAISSER UN PAIEMENT ---
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
            labelStyle: TextStyle(color: Color(0xFF40FFFF)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF40FFFF))),
          )
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Annuler", style: TextStyle(color: Colors.white54))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF40FFFF)),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                state.addPayment(id, double.parse(controller.text));
                Navigator.pop(context);
              }
            }, 
            child: const Text("Valider", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    // Filtrer les transactions pour ne garder que celles de ce contact
    final history = state.activeTransactions.where((t) => t.personName == contactName).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
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
            backgroundColor: Color(0xFF40FFFF), 
            child: Icon(Icons.person, size: 45, color: Colors.black)
          ),
          const SizedBox(height: 15),
          Text(contactName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Divider(color: Colors.white10, height: 40),
          ),
          
          Expanded(
            child: history.isEmpty 
            ? const Center(child: Text("Aucune transaction trouvée", style: TextStyle(color: Colors.white24)))
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, i) {
                  final t = history[i];
                  bool isCompleted = t.remainingAmount <= 0;

                  return Card(
                    color: Colors.white.withOpacity(0.05),
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ExpansionTile(
                      iconColor: const Color(0xFF40FFFF),
                      collapsedIconColor: Colors.white54,
                      title: Text(
                        state.formatAmount(t.amount), 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text(
                        "Reste: ${state.formatAmount(t.remainingAmount)}", 
                        style: TextStyle(color: isCompleted ? Colors.greenAccent : Colors.redAccent, fontSize: 13)
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.share, color: Color(0xFF40FFFF), size: 20),
                        onPressed: () => _partagerRecu(t, state.currentUserName, state),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- CORRECTION PHOTO ---
                              // On teste directement la présence de l'URL
                              if (t.photoUrl != null && t.photoUrl!.isNotEmpty) ...[
                                const Text("Preuve / Photo :", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    t.photoUrl!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 100,
                                      color: Colors.white10,
                                      child: const Center(child: Icon(Icons.broken_image, color: Colors.white24)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],

                              // --- CORRECTION SIGNATURE ---
                              // Si 'hasSignature' n'est pas reconnu, assure-toi qu'il existe dans ton modèle
                              // Sinon, on peut tester si une donnée de signature existe.
                              if (t.hasSignature == true) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.edit, color: Color(0xFF40FFFF), size: 16),
                                    const SizedBox(width: 5),
                                    const Text("Document signé numériquement", style: TextStyle(color: Color(0xFF40FFFF), fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],

                              if (t.note.isNotEmpty) ...[
                                Text("Note: ${t.note}", style: const TextStyle(color: Colors.white70)),
                                const SizedBox(height: 15),
                              ],
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Date: ${t.date.day}/${t.date.month}/${t.date.year}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                  isCompleted 
                                  ? const Text("✅ TERMINÉE", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF40FFFF),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                      ),
                                      onPressed: () => _showPayDialog(context, state, t.id),
                                      child: const Text("ENCAISSER", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                ],
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