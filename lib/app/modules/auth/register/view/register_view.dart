import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // AJOUTÉ
import 'package:voucho/providers/app_state.dart'; // AJOUTÉ
import 'package:voucho/utils/colors.dart';
import '../../../../components/button_components.dart';
import '../../../../components/form_components.dart';
import '../../../../components/space.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleRegister(BuildContext context) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs"), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        // INITIALISATION DE L'APP STATE
        Provider.of<AppState>(context, listen: false).init();
        
        Navigator.pop(context); // Ferme le loader
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }

    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);
      String message = "Erreur lors de l'inscription";
      if (e.code == 'email-already-in-use') message = "Cet email est déjà utilisé.";
      else if (e.code == 'weak-password') message = "Mot de passe trop court.";
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur inconnue : $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.person_add_outlined, size: 80, color: AppColors.primary),
                Space.h20,
                const Text("Créer un compte", 
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)
                ),
                Space.h30,
                CustomTextField(
                  label: "Nom d'utilisateur", 
                  icon: Icons.person_outline, 
                  controller: _usernameController,
                ),
                Space.h20,
                CustomTextField(
                  label: "Email", 
                  icon: Icons.email_outlined, 
                  controller: _emailController,
                ),
                Space.h20,
                CustomTextField(
                  label: "Mot de passe", 
                  icon: Icons.lock_outline, 
                  controller: _passwordController, 
                  isPassword: true,
                ),
                const SizedBox(height: 40), 
                PrimaryButton(
                  label: "S'inscrire", 
                  onPressed: () => _handleRegister(context),
                ),
                Space.h20,
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Déjà un compte ? Se connecter", style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}