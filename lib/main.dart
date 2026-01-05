import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importations de tes dossiers (Vérifie bien que les chemins correspondent à ton projet)
import 'package:voucho/providers/app_state.dart';
import 'package:voucho/app/modules/home/view/home_view.dart';
import 'package:voucho/app/modules/auth/login/view/login_view.dart'; 
import 'package:voucho/app/modules/auth/register/view/register_view.dart';
import 'package:voucho/app/modules/transactions/add/view/add_transaction_view.dart';
import 'package:voucho/app/modules/transactions/detail/view/detail_view.dart';
import 'package:voucho/app/modules/contact/view/contacts_view.dart';
import 'package:voucho/app/modules/contact/view/contact_detail_view.dart';
import 'package:voucho/settings/view/settings_view.dart';

void main() async {
  // 1. Initialisation de Flutter et Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // 2. Vérification immédiate : un utilisateur est-il déjà connecté ?
  User? user = FirebaseAuth.instance.currentUser;
  
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        AppState state = AppState();
        // Si l'utilisateur est déjà là, on charge ses dettes tout de suite
        if (user != null) {
          state.init(); 
        }
        return state;
      },
      // On passe l'écran de départ selon l'état de connexion
      child: MyApp(startScreen: user == null ? '/login' : '/home'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String startScreen;
  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voucho',
      debugShowCheckedModeBanner: false,
      
      // Thème sombre élégant pour ton app
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: const Color(0xFF0D1B1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B1E),
          elevation: 0,
        ),
      ),

      // Définition de la route initiale
      initialRoute: startScreen, 

      // Table des routes pour la navigation
      routes: {
        '/login': (context) => LoginView(),
        '/register': (context) => RegisterView(),
        '/home': (context) => const HomeView(),
        '/add': (context) => const AddTransactionView(),
        '/details': (context) => const DetailsView(),
        '/settings': (context) => const SettingsView(),
        '/contacts': (context) => const ContactsView(),
        '/details_contact': (context) {
          // Gestion sécurisée des arguments pour les détails de contact
          final args = ModalRoute.of(context)!.settings.arguments;
          final String name = args is String ? args : "Inconnu";
          return ContactDetailView(contactName: name);
        },
      },
    );
  }
}