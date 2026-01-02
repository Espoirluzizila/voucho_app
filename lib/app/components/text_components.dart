import 'package:flutter/material.dart';
import 'package:voucho_app/utils/colors.dart';// Importation relative plus robuste

class TextComponents {
  static TextStyle title = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static TextStyle subtitle = const TextStyle(
    fontSize: 16,
    color: AppColors.textLight,
  );

  static TextStyle amountDebt = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.danger,
  );

  static TextStyle amountLoan = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );
}