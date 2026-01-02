import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import '../app/components/space.dart';

class TransactionCard extends StatelessWidget {
  final String name;
  final double amount;
  final bool isDebt;
  final String date;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.name,
    required this.amount,
    required this.isDebt,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDebt ? AppColors.danger.withOpacity(0.1) : AppColors.accent.withOpacity(0.1),
              child: Icon(
                isDebt ? Icons.arrow_downward : Icons.arrow_upward,
                color: isDebt ? AppColors.danger : AppColors.accent,
                size: 20,
              ),
            ),
            Space.w20,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(date, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                ],
              ),
            ),
            Text(
              "${isDebt ? '-' : '+'}${Helpers.formatMoney(amount)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDebt ? AppColors.danger : AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}