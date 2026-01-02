import '../../models/transaction.dart';

class SampleData {
  static List<TransactionModel> dummyTransactions = [
    TransactionModel(
      id: "1",
      contactName: "Jean-Pierre",
      amount: 5000,
      isDebt: true, // Dette
      date: DateTime.now().subtract(const Duration(days: 1)),
      isPaid: false,
    ),
    TransactionModel(
      id: "2",
      contactName: "Sarah M.",
      amount: 15000,
      isDebt: false, // Prêt
      date: DateTime.now().subtract(const Duration(days: 2)),
      isPaid: false,
    ),
    TransactionModel(
      id: "3",
      contactName: "Boulangerie",
      amount: 1200,
      isDebt: true,
      date: DateTime.now().subtract(const Duration(days: 5)),
      isPaid: true,
    ),
  ];
}