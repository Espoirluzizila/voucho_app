import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importations des composants (Vérifie bien ces chemins dans ton projet)
import 'package:voucho_app/utils/colors.dart'; 
import '../../../../components/button_components.dart';
import '../../../../components/form_components.dart';
import '../../../../components/space.dart';

// Importations des vues
// Note : Si "RegisterView" est toujours rouge, c'est que le chemin ci-dessous est différent chez toi
import '../../register/view/register_view.dart'; 
import '../../../home/view/home_view.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      }

    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);
      
      String errorMsg = "Erreur de connexion";
      if (e.code == 'user-not-found') errorMsg = "Utilisateur non trouvé";
      else if (e.code == 'wrong-password') errorMsg = "Mot de passe incorrect";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Icon(Icons.account_balance_wallet, size: 80, color: AppColors.primary),
                Space.h20,
                const Text("Voucho", 
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)
                ),
                Space.h30,
                CustomTextField(
                  label: "Email", 
                  icon: Icons.email_outlined, 
                  controller: _emailController
                ),
                Space.h20,
                CustomTextField(
                  label: "Mot de passe", 
                  icon: Icons.lock_outline, 
                  controller: _passwordController, 
                  isPassword: true
                ),
                Space.h30,
                PrimaryButton(
                  label: "Se connecter", 
                  onPressed: () => _handleLogin(context),
                ),
                Space.h10,
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  RegisterView()),
                    );
                  },
                  child: const Text(
                    "Pas encore de compte ? Créer ici", 
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}