import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String contactName;
  final double amount;
  final bool isDebt; // true = Je dois (Dette), false = On me doit (Prêt)
  final DateTime date;
  final bool isPaid;

  TransactionModel({
    required this.id,
    required this.contactName,
    required this.amount,
    required this.isDebt,
    required this.date,
    this.isPaid = false,
  });

  // Convertit un document Firestore en objet TransactionModel
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      contactName: data['contactName'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      isDebt: data['isDebt'] ?? true,
      date: (data['date'] as Timestamp).toDate(),
      isPaid: data['isPaid'] ?? false,
    );
  }

  // Convertit l'objet en Map pour l'envoyer vers Firestore
  Map<String, dynamic> toMap() {
    return {
      'contactName': contactName,
      'amount': amount,
      'isDebt': isDebt,
      'date': date,
      'isPaid': isPaid,
    };
  }
}