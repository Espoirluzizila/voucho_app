import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({super.key});
  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'loan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enregistrer une dette/prêt")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () { /* Ici code pour ouvrir la galerie photo */ },
              child: const CircleAvatar(radius: 40, child: Icon(Icons.add_a_photo)),
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nom de la personne")),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: "Montant"), keyboardType: TextInputType.number),
            DropdownButton<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'loan', child: Text("Je lui ai prêté (Il me doit)")),
                DropdownMenuItem(value: 'debt', child: Text("Il m'a prêté (Je lui dois)")),
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("ENREGISTRER"),
            )
          ],
        ),
      ),
    );
  }

  void _save() async {
    final user = FirebaseAuth.instance.currentUser;
    double amount = double.parse(_amountController.text);
    await FirebaseFirestore.instance.collection('transactions').add({
      'userId': user!.uid,
      'personName': _nameController.text,
      'amount': amount,
      'remainingAmount': amount, // Au début, le reste est égal au total
      'type': _type,
      'date': DateTime.now(),
      'isPaid': false,
    });
    Navigator.pop(context);
  }
}