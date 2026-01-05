import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voucho/providers/app_state.dart';

class ContactsView extends StatelessWidget {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    // CORRECTION : allContactNames est maintenant disponible via le getter ajouté ci-dessus
    final contactNames = state.allContactNames;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text("Mes Contacts", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: contactNames.isEmpty 
        ? const Center(
            child: Text(
              "Aucun contact enregistré", 
              style: TextStyle(color: Colors.white54)
            )
          )
        : ListView.builder(
            itemCount: contactNames.length,
            itemBuilder: (context, i) {
              final name = contactNames[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.cyan,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?", 
                    style: const TextStyle(color: Colors.white)
                  ),
                ),
                title: Text(
                  name, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
                subtitle: const Text(
                  "Appuyez pour voir l'historique", 
                  style: TextStyle(color: Colors.white54)
                ),
                trailing: const Icon(Icons.history, color: Colors.cyan),
                onTap: () {
                  // Assure-toi que cette route est bien définie dans ton main.dart
                  Navigator.pushNamed(
                    context, 
                    '/details_contact', 
                    arguments: name
                  );
                },
              );
            },
          ),
    );
  }
}