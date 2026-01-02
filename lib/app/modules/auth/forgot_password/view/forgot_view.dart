import 'package:flutter/material.dart';
import '../../../../components/button_components.dart';
import '../../../../components/form_components.dart';
import '../../../../components/space.dart';
import 'package:voucho_app/utils/colors.dart';

class ForgotView extends StatelessWidget {
  ForgotView({super.key});

  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.primary)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Mot de passe oublié ?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            Space.h10,
            const Text("Entrez votre email pour recevoir un lien de réinitialisation."),
            Space.h30,
            CustomTextField(label: "Email", icon: Icons.email_outlined, controller: _emailController),
            Space.h30,
            PrimaryButton(label: "Envoyer le lien", onPressed: () {
              // Logique de reset
            }),
          ],
        ),
      ),
    );
  }
}