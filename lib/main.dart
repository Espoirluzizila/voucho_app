import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Importations des Providers
import 'package:voucho_app/providers/app_state.dart';

// Importations des Vues
import 'app/modules/splash/view/splash_view.dart';
import 'app/modules/auth/login/view/login_view.dart';
import 'app/modules/home/view/home_view.dart';
import 'package:voucho_app/app/modules/transactions/view/add_transaction_view.dart';
import 'app/modules/details/view/transaction_details_view.dart';
import 'package:voucho_app/app/modules/contact/view/contacts_view.dart';
import 'package:voucho_app/app/modules/contact/view/contact_detail_view.dart'; // Assure-toi que ce fichier existe

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState()..init(),
      child: const VouchoApp(),
    ),
  );
}

class VouchoApp extends StatelessWidget {
  const VouchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voucho',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashView(),
        '/': (context) => LoginView(),
        '/home': (context) => const HomeView(),
        '/add_transaction': (context) => const AddTransactionView(),
        '/details': (context) => const TransactionDetailsView(),
        '/contacts': (context) => const ContactsView(),
        // Route dynamique pour voir l'historique d'un contact précis
        '/details_contact': (context) {
           final name = ModalRoute.of(context)!.settings.arguments as String;
           return ContactDetailView(contactName: name);
        },
      },
    );
  }
}