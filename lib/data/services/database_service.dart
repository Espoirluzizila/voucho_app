import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voucho/data/models/transaction_model.dart'; // Vérifie bien ce chemin

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Récupère l'UID de l'utilisateur actuel
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? "";

  // --- AJOUTER UNE TRANSACTION ---
  Future<void> addTransaction(String name, double amount, String type, {String note = ""}) async {
    if (uid.isEmpty) return;

    await _db.collection('transactions').add({
      'userId': uid,
      'personName': name,
      'amount': amount,
      'remainingAmount': amount, // Initialisé au montant total
      'type': type,
      'note': note,
      'date': FieldValue.serverTimestamp(), // Date officielle du serveur Firebase
      'status': 'active',
    });
  }

  // --- LIRE LES TRANSACTIONS EN TEMPS RÉEL ---
  Stream<List<TransactionModel>> get transactions {
    if (uid.isEmpty) return Stream.value([]);

    return _db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              // ON UTILISE .fromMap car c'est le nom dans ton fichier model
              return TransactionModel.fromMap(
                doc.data() as Map<String, dynamic>, 
                doc.id,
              );
            }).toList());
  }

  // --- SUPPRIMER UNE TRANSACTION ---
  Future<void> deleteTransaction(String id) async {
    if (id.isEmpty) return;
    await _db.collection('transactions').doc(id).delete();
  }

  // --- ENCAISSER UN PAIEMENT (Mise à jour du reste à payer) ---
  Future<void> updateRemainingAmount(String id, double newRemaining) async {
    await _db.collection('transactions').doc(id).update({
      'remainingAmount': newRemaining,
      'status': newRemaining <= 0 ? 'completed' : 'active',
    });
  }
}