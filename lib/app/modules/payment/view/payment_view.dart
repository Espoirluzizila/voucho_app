import 'package:flutter/material.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement Sécurisé")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text("Lier votre compte pour payer", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {}, 
              child: const Text("Payer via Mobile Money (Airtel/Orange/Mpesa)"),
            ),
          ],
        ),
      ),
    );
  }
}