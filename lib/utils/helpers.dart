import 'package:intl/intl.dart';

class Helpers {
  // Formate le montant (ex: 15000 -> 15 000 FC)
  static String formatMoney(double amount) {
    return NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FC', // Change ici pour $ si besoin
      decimalDigits: 0,
    ).format(amount);
  }

  // Formate la date (ex: 2025-12-31 -> 31 déc. 2025)
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
  }
}