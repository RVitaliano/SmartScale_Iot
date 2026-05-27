import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pesagem_model.dart';
import '../app_colors.dart';
import 'classification_badge.dart';

class PesagemListTile extends StatelessWidget {
  final PesagemModel pesagem;

  const PesagemListTile({super.key, required this.pesagem});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm:ss');
    final isSobrepeso = pesagem.status.toLowerCase() == 'sobrepeso';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineSoft),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              timeFmt.format(pesagem.timestamp.toLocal()),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppColors.onSurfaceDim,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${pesagem.pesoKg.toStringAsFixed(2)} kg',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSobrepeso ? AppColors.danger : AppColors.onSurface,
              ),
            ),
          ),
          ClassificationBadge(classificacao: pesagem.classificacao),
        ],
      ),
    );
  }
}
