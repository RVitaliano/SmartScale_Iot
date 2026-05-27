import 'package:flutter/material.dart';
import '../app_colors.dart';

class ClassificationBadge extends StatelessWidget {
  final String classificacao;

  const ClassificationBadge({super.key, required this.classificacao});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromClassificacao(classificacao);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        classificacao.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
