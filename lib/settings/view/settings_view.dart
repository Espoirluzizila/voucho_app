import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voucho/providers/app_state.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        title: const Text("Paramètres des Taux", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text(
            "Définir la valeur pour 1 USD (\$)",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          
          // Case pour le Franc Congolais
          _buildRateInput(
            context, 
            state, 
            "FC", 
            "Franc Congolais", 
            Icons.money_off_csred_outlined
          ),
          
          const SizedBox(height: 15),
          
          // Case pour l'Euro
          _buildRateInput(
            context, 
            state, 
            "EUR", 
            "Euro", 
            Icons.euro_symbol
          ),
          
          const SizedBox(height: 15),
          
          // Case pour le Rouble
          _buildRateInput(
            context, 
            state, 
            "RUB", 
            "Rouble Russe", 
            Icons.currency_ruble
          ),

          const SizedBox(height: 40),
          const Text(
            "Note : Le taux USD reste toujours à 1.0 par défaut.",
            style: TextStyle(color: Colors.white24, fontSize: 12, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRateInput(BuildContext context, AppState state, String code, String label, IconData icon) {
    // On récupère le taux actuel depuis la Map exchangeRates du AppState
    double currentRate = state.exchangeRates[code] ?? 0.0;
    final controller = TextEditingController(text: currentRate.toString());

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF40FFFF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(icon, color: Colors.white54),
                    hintText: "Entrez le taux",
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40FFFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  double? val = double.tryParse(controller.text);
                  if (val != null && val > 0) {
                    state.updateRate(code, val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Taux $code mis à jour !"), backgroundColor: Colors.teal),
                    );
                  }
                },
                child: const Text("OK", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}