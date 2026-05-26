import 'package:flutter/material.dart';
import '../app_colors.dart';

class ClassificationBadge extends StatelessWidget {
  final String classificacao;

  const ClassificationBadge({super.key, required this.classificacao});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromClassificacao(classificacao);
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 8),
      label: Text(
        classificacao,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(color: color),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
