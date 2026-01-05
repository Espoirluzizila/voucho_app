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
  
  // NOUVEAUX CHAMPS AJOUTÉS ICI
  final String? photoUrl;
  final bool hasPhoto;
  final bool hasSignature;

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
    this.photoUrl,
    this.hasPhoto = false,
    this.hasSignature = false,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      userId: map['userId'] ?? '',
      personName: map['personName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      remainingAmount: (map['remainingAmount'] ?? 0.0).toDouble(),
      type: map['type'] ?? 'loan',
      note: map['note'] ?? '',
      date: (map['date'] != null) 
          ? (map['date'] as Timestamp).toDate() 
          : DateTime.now(),
      status: map['status'] ?? 'active',
      // MAPPING DES NOUVEAUX CHAMPS
      photoUrl: map['photoUrl'],
      hasPhoto: map['hasPhoto'] ?? false,
      hasSignature: map['hasSignature'] ?? false,
    );
  }

  // Optionnel : Ajoute une méthode toMap si tu dois enregistrer sur Firebase
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
      'photoUrl': photoUrl,
      'hasPhoto': hasPhoto,
      'hasSignature': hasSignature,
    };
  }
}