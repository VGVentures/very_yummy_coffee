import 'package:flutter/material.dart';

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    required this.label,
    required this.amount,
    required this.style,
    super.key,
  });

  final String label;
  final int amount;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('\$${(amount / 100).toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
