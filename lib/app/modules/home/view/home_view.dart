import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voucho_app/providers/app_state.dart';
import 'package:voucho_app/data/models/transaction_model.dart';
import 'package:voucho_app/utils/colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background, // On utilise ta couleur de fond définie
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Bonjour,", style: TextStyle(color: Colors.white54, fontSize: 16)),
                      Text(state.currentUserName, 
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- CARTE DE SOLDE (SANS IMAGE DE FOND POUR ÉVITER L'ERREUR) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // On utilise un dégradé de couleurs au lieu d'une image assets
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF006064)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Solde Net", style: TextStyle(color: Colors.white70)),
                        GestureDetector(
                          onTap: () => state.toggleCurrency(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(state.isUSD ? "USD" : "CDF", 
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.formatAmount(state.totalLoans - state.totalDebts),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _balanceInfo("On me doit", state.formatAmount(state.totalLoans), Icons.arrow_downward, Colors.greenAccent),
                        _balanceInfo("Je dois", state.formatAmount(state.totalDebts), Icons.arrow_upward, Colors.orangeAccent),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- OPÉRATIONS RÉCENTES ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Opérations récentes", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => _showUpdateTauxDialog(context, state),
                    child: Text("Taux: ${state.tauxChange.toStringAsFixed(0)}", 
                      style: const TextStyle(color: Colors.cyanAccent)),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('transactions')
                      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text("Aucune donnée", style: TextStyle(color: Colors.white54)));
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final t = TransactionModel.fromMap(data, docs[i].id);

                        return Card(
                          color: Colors.white.withOpacity(0.05),
                          child: ListTile(
                            onTap: () => Navigator.pushNamed(context, '/details', arguments: t),
                            leading: Icon(
                              t.type == 'loan' ? Icons.add_circle_outline : Icons.remove_circle_outline,
                              color: t.type == 'loan' ? Colors.greenAccent : Colors.redAccent,
                            ),
                            title: Text(t.personName, style: const TextStyle(color: Colors.white)),
                            subtitle: Text("Reste: ${state.formatAmount(t.remainingAmount)}", style: const TextStyle(color: Colors.white54)),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _balanceInfo(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  void _showUpdateTauxDialog(BuildContext context, AppState state) {
    final controller = TextEditingController(text: state.tauxChange.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3339),
        title: const Text("Modifier le taux", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Ex: 21200", hintStyle: TextStyle(color: Colors.white24)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              state.updateTaux(double.parse(controller.text));
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}