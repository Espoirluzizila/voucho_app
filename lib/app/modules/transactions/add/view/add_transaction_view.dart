import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voucho/utils/colors.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Importations de tes composants personnalisés
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
  
  // --- SIGNATURE ---
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // --- PHOTO ---
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String _transactionType = 'loan'; 
  bool _isLoading = false;

  // --- LOGIQUE PHOTO (CAMERA + GALERIE) ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Optimisé pour la connexion en RDC
      );
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la sélection : $e")),
      );
    }
  }

  // Affiche le menu de choix en bas de l'écran
  void _showPickerMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.cyan),
                title: const Text('Galerie', style: TextStyle(color: Colors.white)),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.cyan),
                title: const Text('Appareil photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- ENREGISTREMENT ---
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
        'remainingAmount': amount,
        'type': _transactionType,
        'note': _noteController.text.trim(),
        'date': DateTime.now(),
        'status': 'active',
        'hasSignature': _signatureController.isNotEmpty,
        'hasPhoto': _imageFile != null,
      });

      if (mounted) {
        Navigator.pop(context);
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
  void dispose() {
    _signatureController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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
                Expanded(child: _typeButton("On me doit", 'loan', Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _typeButton("Je dois", 'debt', Colors.red)),
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
              keyboardType: TextInputType.number,
            ),
            Space.h20,
            
            // --- SECTION PHOTO ---
            const Text("Photo de la personne ou preuve", style: TextStyle(fontWeight: FontWeight.bold)),
            Space.h10,
            GestureDetector(
              onTap: _showPickerMenu, // C'est ici que l'on appelle le menu
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: _imageFile == null 
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.cyan),
                        Text("Ajouter une image", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
              ),
            ),
            Space.h20,

            // --- SECTION SIGNATURE ---
            const Text("Signature du prêteur/emprunteur :", style: TextStyle(fontWeight: FontWeight.bold)),
            Space.h10,
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Signature(
                  controller: _signatureController,
                  height: 150,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _signatureController.clear(),
                icon: const Icon(Icons.clear, size: 18, color: Colors.red),
                label: const Text("Effacer la signature", style: TextStyle(color: Colors.red)),
              ),
            ),

            Space.h20,
            CustomTextField(
              label: "Note (optionnel)",
              icon: Icons.description_outlined,
              controller: _noteController,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
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
          color: isSelected ? color : Colors.transparent,
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