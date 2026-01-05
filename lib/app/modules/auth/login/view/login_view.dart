import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:voucho/providers/app_state.dart';

// Importations des composants
import 'package:voucho/utils/colors.dart'; 
import 'package:voucho/app/components/button_components.dart';
import 'package:voucho/app/components/form_components.dart';
import 'package:voucho/app/components/space.dart';

// Importations des vues (Utilisation des chemins complets pour éviter les erreurs)
import 'package:voucho/app/modules/auth/register/view/register_view.dart'; 
import 'package:voucho/app/modules/home/view/home_view.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (context.mounted) {
        // IMPORTANT : Charger les données Firestore avant de changer d'écran
        Provider.of<AppState>(context, listen: false).init();
        
        Navigator.pop(context); // Fermer le loader

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }

    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);
      
      String errorMsg = "Erreur de connexion";
      if (e.code == 'user-not-found') {
        errorMsg = "Aucun utilisateur trouvé.";
      } else if (e.code == 'wrong-password') {
        errorMsg = "Mot de passe incorrect.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Une erreur est survenue"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet, 
                    size: 100, 
                    color: AppColors.primary
                  ),
                  const SizedBox(height: 20), // Remplacement de Space.h20
                  const Text(
                    "Voucho", 
                    style: TextStyle(
                      fontSize: 40, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.primary,
                      letterSpacing: 1.5
                    )
                  ),
                  const Text(
                    "Gérez vos dettes en toute simplicité",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 40), // Remplacement de Space.h40
                  CustomTextField(
                    label: "Email", 
                    icon: Icons.email_outlined, 
                    controller: _emailController
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: "Mot de passe", 
                    icon: Icons.lock_outline, 
                    controller: _passwordController, 
                    isPassword: true
                  ),
                  const SizedBox(height: 30),
                  PrimaryButton(
                    label: "Se connecter", 
                    onPressed: () => _handleLogin(context),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Nouveau sur Voucho ? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterView()),
                          );
                        },
                        child: const Text(
                          "Créer un compte", 
                          style: TextStyle(
                            color: AppColors.primary, 
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          )
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}