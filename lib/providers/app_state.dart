import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/transaction_model.dart';

class AppState extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TransactionModel> _transactions = [];
  String _currentUserName = "Utilisateur";

  // --- SYSTÈME DE DEVISES ---
  String _currentCurrency = "USD"; // USD, FC, EUR, RUB
  
  // Taux par défaut (1 USD = X devise)
  Map<String, double> _exchangeRates = {
    "USD": 1.0,
    "FC": 2200.0,
    "EUR": 0.85,
    "RUB": 80.30,
  };

  final List<String> currencies = ["USD", "FC", "EUR", "RUB"];

  // --- GETTERS ---
  List<TransactionModel> get activeTransactions => _transactions;
  String get currentCurrency => _currentCurrency;
  String get currentUserName => _currentUserName;
  Map<String, double> get exchangeRates => _exchangeRates;

  List<String> get allContactNames {
    if (_transactions.isEmpty) return [];
    final names = _transactions.map((t) => t.personName).toSet().toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  // --- INITIALISATION ---
  Future<void> init() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _loadSettings(); // Charge la devise et les taux sauvés

    _db.collection('users').doc(user.uid).snapshots().listen((doc) {
      if (doc.exists) {
        _currentUserName = doc.data()?['username'] ?? "Utilisateur";
        notifyListeners();
      }
    });

    _db.collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          try {
            _transactions = snapshot.docs.map((doc) {
              return TransactionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            }).toList();
            _transactions.sort((a, b) => b.date.compareTo(a.date));
            notifyListeners();
          } catch (e) {
            debugPrint("Erreur Firestore: $e");
          }
    });
  }

  // --- PERSISTANCE (Sauvegarde locale) ---
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCurrency = prefs.getString('current_currency') ?? "USD";
    
    // Charger les taux s'ils ont été modifiés par l'utilisateur
    _exchangeRates["FC"] = prefs.getDouble('rate_FC') ?? 2200.0;
    _exchangeRates["EUR"] = prefs.getDouble('rate_EUR') ?? 0.85;
    _exchangeRates["RUB"] = prefs.getDouble('rate_RUB') ?? 80.30;
    
    notifyListeners();
  }

  Future<void> updateRate(String code, double newRate) async {
    if (code == "USD") return; 
    _exchangeRates[code] = newRate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('rate_$code', newRate);
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    _currentCurrency = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_currency', code);
    notifyListeners();
  }

  // --- LOGIQUE DE FORMATAGE DYNAMIQUE ---
  String formatAmount(double amountInUSD) {
    double rate = _exchangeRates[_currentCurrency] ?? 1.0;
    double converted = amountInUSD * rate;

    switch (_currentCurrency) {
      case "FC":
        return "${NumberFormat("#,###", "fr_FR").format(converted)} FC";
      case "EUR":
        return "${converted.toStringAsFixed(2)} €";
      case "RUB":
        return "${converted.toStringAsFixed(2)} ₽";
      default:
        return "${converted.toStringAsFixed(2)} \$";
    }
  }

  // --- ACTIONS FIREBASE (Inchangées) ---
  Future<void> addPayment(String id, double paid) async {
    final docRef = _db.collection('transactions').doc(id);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      double currentRem = (snap.data()?['remainingAmount'] ?? 0.0).toDouble();
      double newRem = currentRem - paid;
      tx.update(docRef, {
        'remainingAmount': newRem < 0 ? 0.0 : newRem, 
        'status': newRem <= 0 ? 'completed' : 'active'
      });
    });
  }

  Future<void> resetAllTransactions() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final collection = await _db.collection('transactions').where('userId', isEqualTo: user.uid).get();
    final batch = _db.batch();
    for (var doc in collection.docs) { batch.delete(doc.reference); }
    await batch.commit();
  }

  double get totalLoans => _transactions.where((t) => t.type == 'loan').fold(0.0, (p, e) => p + e.remainingAmount);
  double get totalDebts => _transactions.where((t) => t.type == 'debt').fold(0.0, (p, e) => p + e.remainingAmount);
}