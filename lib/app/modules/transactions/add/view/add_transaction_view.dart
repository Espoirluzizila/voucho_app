import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voucho_app/utils/colors.dart';
import '../../../../components/button_components.dart';
import '../../../../components/form_components.dart';
import '../../../../components/space.dart';

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({super.key});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  // 'loan' = on me doit (vert), 'debt' = je dois (rouge)
  String _transactionType = 'loan'; 
  bool _isLoading = false;

  Future<void> _saveTransaction() async {
    final String name = _nameController.text.trim();
    final String amountStr = _amountController.text.trim();

    if (name.isEmpty || amountStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir le nom et le montant")),
      );
      return;
    }

    final double amount = double.tryParse(amountStr) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Montant invalide")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': user.uid,
        'personName': name,
        'amount': amount,
        'remainingAmount': amount, // Au début, tout reste à payer
        'type': _transactionType,
        'note': _noteController.text.trim(),
        'date': DateTime.now(),
        'status': 'active', // active, completed
      });

      if (mounted) {
        Navigator.pop(context); // Retour à la home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enregistré avec succès"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Nouvelle opération", style: TextStyle(color: AppColors.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Type d'opération", style: TextStyle(fontWeight: FontWeight.bold)),
            Space.h10,
            Row(
              children: [
                Expanded(
                  child: _typeButton("On me doit", 'loan', Colors.green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _typeButton("Je dois", 'debt', Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 30),
            CustomTextField(
              label: "Nom de la personne",
              icon: Icons.person_outline,
              controller: _nameController,
            ),
            Space.h20,
            CustomTextField(
              label: "Montant (en USD \$)",
              icon: Icons.attach_money,
              controller: _amountController,
              // Pour n'autoriser que les chiffres et le point
              keyboardType: TextInputType.number,
            ),
            Space.h20,
            CustomTextField(
              label: "Note (optionnel)",
              icon: Icons.description_outlined,
              controller: _noteController,
            ),
            const SizedBox(height: 50),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : PrimaryButton(
                    label: "Enregistrer l'opération",
                    onPressed: _saveTransaction,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String label, String type, Color color) {
    bool isSelected = _transactionType == type;
    return GestureDetector(
      onTap: () => setState(() => _transactionType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}