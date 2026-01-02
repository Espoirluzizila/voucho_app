import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String personName;
  final double amount;
  final double remainingAmount;
  final String type; // 'loan' ou 'debt'
  final String note;
  final DateTime date;
  final String status;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.personName,
    required this.amount,
    required this.remainingAmount,
    required this.type,
    required this.note,
    required this.date,
    required this.status,
  });

  // --- C'EST CETTE PARTIE QUI MANQUE OU EST MAL ÉCRITE ---
  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      userId: map['userId'] ?? '',
      personName: map['personName'] ?? '',
      // On s'assure que les nombres sont bien convertis en double
      amount: (map['amount'] ?? 0.0).toDouble(),
      remainingAmount: (map['remainingAmount'] ?? 0.0).toDouble(),
      type: map['type'] ?? 'loan',
      note: map['note'] ?? '',
      // Gestion de la date Firestore (Timestamp vers DateTime)
      date: (map['date'] as Timestamp).toDate(),
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'personName': personName,
      'amount': amount,
      'remainingAmount': remainingAmount,
      'type': type,
      'note': note,
      'date': date,
      'status': status,
    };
  }
}