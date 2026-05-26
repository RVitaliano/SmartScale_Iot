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
    final fmt = DateFormat('dd/MM/yyyy HH:mm:ss');
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              AppColors.fromClassificacao(pesagem.classificacao).withValues(alpha: 0.2),
          child: Text(
            pesagem.pesoKg.toStringAsFixed(1),
            style: TextStyle(
              color: AppColors.fromClassificacao(pesagem.classificacao),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${pesagem.pesoKg.toStringAsFixed(2)} kg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          fmt.format(pesagem.timestamp.toLocal()),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: ClassificationBadge(classificacao: pesagem.classificacao),
      ),
    );
  }
}
