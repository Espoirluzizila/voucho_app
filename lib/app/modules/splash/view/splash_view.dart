import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../utils/colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Configuration de l'animation (2 secondes)
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 2)
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    
    // Lancement de l'animation
    _controller.forward();

    // Redirection après 4 secondes vers la page de connexion (/)
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 1. Arrière-plan avec ton image im.webp
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/im.webp"),
            fit: BoxFit.cover,
          ),
        ),
        // 2. Overlay (couche de couleur) par-dessus l'image
        child: Container(
          color: AppColors.primary.withOpacity(0.8), 
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo officiel
                const Icon(
                  Icons.account_balance_wallet, 
                  size: 120, 
                  color: Colors.white
                ),
                const SizedBox(height: 20),
                // Nom de l'application
                const Text(
                  "Voucho",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                // Phrase d'accroche
                Text(
                  "Gérez vos comptes en confiance",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9), 
                    fontSize: 16,
                    fontStyle: FontStyle.italic
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