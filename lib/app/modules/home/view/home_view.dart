import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voucho/providers/app_state.dart';
import 'package:voucho/data/models/transaction_model.dart'; 

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // Fonction de confirmation pour supprimer les transactions
  void _confirmReset(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3339),
        title: const Text("Supprimer tout ?", style: TextStyle(color: Colors.white)),
        content: const Text("Cette action effacera toutes vos transactions définitivement.", 
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              state.resetAllTransactions();
              Navigator.pop(context);
            },
            child: const Text("OUI, EFFACER"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_home.jpg"), 
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // --- HEADER : USERNAME & SETTINGS & CURRENCY ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          const Text("Bonjour,", style: TextStyle(color: Colors.white70)),
                          Text(
                            state.currentUserName, 
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                          ),
                        ]
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white70, size: 26),
                          onPressed: () => Navigator.pushNamed(context, '/settings'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 28),
                          onPressed: () => _confirmReset(context, state),
                        ),
                        const SizedBox(width: 5),
                        _currencyBadge(state),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // --- CARTE DE SOLDE PRINCIPALE ---
                _buildBalanceCard(state),
                const SizedBox(height: 30),

                // --- LISTE DES TRANSACTIONS ---
                _buildListHeader(context),
                Expanded(child: _buildList(state)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF40FFFF),
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add, color: Colors.black, size: 35),
      ),
    );
  }

  // --- WIDGET DU SÉLECTEUR DE DEVISE (CORRIGÉ) ---
  Widget _currencyBadge(AppState state) {
    return PopupMenuButton<String>(
      onSelected: (String code) => state.setCurrency(code),
      initialValue: state.currentCurrency,
      color: const Color(0xFF1B3339), // Correction : color au lieu de backgroundColor
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10, 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: Colors.white24)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.currentCurrency, 
              style: const TextStyle(color: Color(0xFF40FFFF), fontWeight: FontWeight.bold)
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 18),
          ],
        ),
      ),
      itemBuilder: (context) => state.currencies.map((String c) {
        return PopupMenuItem<String>(
          value: c,
          child: Row(
            children: [
              Icon(
                Icons.monetization_on_outlined, 
                color: state.currentCurrency == c ? const Color(0xFF40FFFF) : Colors.white54, 
                size: 18
              ),
              const SizedBox(width: 10),
              Text(c, style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBalanceCard(AppState state) {
    double soldeGlobal = state.totalLoans - state.totalDebts;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF00ACC1), Color(0xFF007A8A)]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(children: [
        const Text("Solde à recouvrer", style: TextStyle(color: Colors.white70)),
        SizedBox(
          height: 50,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              state.formatAmount(soldeGlobal), 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Expanded(child: _miniCol("On me doit", state.formatAmount(state.totalLoans))),
          Expanded(child: _miniCol("Je dois", state.formatAmount(state.totalDebts))),
        ])
      ]),
    );
  }

  Widget _miniCol(String t, String v) => Column(children: [
    Text(t, style: const TextStyle(color: Colors.white60, fontSize: 12)),
    FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  ]);

  Widget _buildListHeader(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text("Dettes en cours", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      TextButton(
        onPressed: () => Navigator.pushNamed(context, '/contacts'), 
        child: const Text("Mes Contacts", style: TextStyle(color: Color(0xFF40FFFF)))
      ),
    ]);
  }

  Widget _buildList(AppState state) {
    if (state.activeTransactions.isEmpty) return const Center(child: Text("Aucune dette", style: TextStyle(color: Colors.white24)));
    
    return ListView.builder(
      itemCount: state.activeTransactions.length,
      itemBuilder: (context, i) {
        final TransactionModel t = state.activeTransactions[i]; 
        
        return Card(
          color: Colors.white.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            onTap: () => Navigator.pushNamed(context, '/details', arguments: t),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.type == 'loan' ? Colors.greenAccent : Colors.redAccent, 
                  width: 2
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: (t.photoUrl != null && t.photoUrl!.isNotEmpty) 
                  ? Image.network(
                      t.photoUrl!, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => _iconFallback(t),
                    ) 
                  : _iconFallback(t),
              ),
            ),
            title: Text(t.personName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Montant converti dynamiquement selon le choix de l'utilisateur
                Text("Reste: ${state.formatAmount(t.remainingAmount)}", style: const TextStyle(color: Colors.white54, fontSize: 13)),
                
                // Si ce n'est pas déjà du USD, on affiche un rappel en Dollars
                if (state.currentCurrency != "USD") 
                   Text("${t.remainingAmount.toStringAsFixed(2)} \$", style: const TextStyle(color: Colors.white24, fontSize: 10)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
          ),
        );
      },
    );
  }

  Widget _iconFallback(TransactionModel t) {
    return Icon(
      t.type == 'loan' ? Icons.arrow_downward : Icons.arrow_upward, 
      color: t.type == 'loan' ? Colors.greenAccent : Colors.redAccent
    );
  }
}