import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../data/models/transaction_model.dart';

class AppState extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- VARIABLES D'ÉTAT ---
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  bool _isUSD = true; 
  double _tauxChange = 2120.0; // Ton taux par défaut
  String _currentUserName = "Utilisateur";

  // --- GETTERS ---
  List<TransactionModel> get activeTransactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isUSD => _isUSD;
  double get tauxChange => _tauxChange;
  String get currentUserName => _currentUserName;

  // --- NOUVEAU GETTER : EXTRACTION DES CONTACTS UNIQUES ---
  List<String> get allContactNames {
    // On extrait les noms, on enlève les doublons avec .toSet() et on trie
    final names = _transactions.map((t) => t.personName).toSet().toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  // --- INITIALISATION ---
  Future<void> init() async {
    final user = _auth.currentUser;
    if (user != null) {
      // 1. Récupérer les infos utilisateur
      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _currentUserName = userDoc.data()?['username'] ?? "Utilisateur";
      }

      // 2. Écouter les transactions en temps réel
      _db.collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {
        _transactions = snapshot.docs.map((doc) {
          return TransactionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  // --- GESTION DEVISE ET TAUX ---
  void toggleCurrency() {
    _isUSD = !_isUSD;
    notifyListeners();
  }

  void updateTaux(double nouveauTaux) {
    _tauxChange = nouveauTaux;
    notifyListeners();
  }

  String formatAmount(double amountInUSD) {
    if (_isUSD) {
      return "${amountInUSD.toStringAsFixed(2)} \$";
    } else {
      double amountInFc = amountInUSD * _tauxChange;
      final formatter = NumberFormat("#,###", "fr_FR");
      return "${formatter.format(amountInFc)} Fc";
    }
  }

  // --- ACTIONS SUR LES TRANSACTIONS ---
  
  // Encaisser un remboursement
  Future<void> addPayment(String transactionId, double paidAmount) async {
    try {
      final docRef = _db.collection('transactions').doc(transactionId);
      
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        double currentRemaining = (snapshot.data()?['remainingAmount'] ?? 0.0).toDouble();
        double newRemaining = currentRemaining - paidAmount;

        if (newRemaining < 0) newRemaining = 0;

        transaction.update(docRef, {
          'remainingAmount': newRemaining,
          'status': newRemaining == 0 ? 'completed' : 'active',
        });
      });
    } catch (e) {
      debugPrint("Erreur paiement: $e");
    }
  }

  // Supprimer
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _db.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      debugPrint("Erreur suppression: $e");
    }
  }

  // --- CALCULS DES SOLDES (Helpers) ---
  double get totalLoans => _transactions
      .where((t) => t.type == 'loan')
      .fold(0.0, (sum, item) => sum + item.remainingAmount);

  double get totalDebts => _transactions
      .where((t) => t.type == 'debt')
      .fold(0.0, (sum, item) => sum + item.remainingAmount);
}