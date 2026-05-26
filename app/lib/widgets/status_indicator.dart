import 'package:flutter/material.dart';
import '../app_colors.dart';

class StatusIndicator extends StatelessWidget {
  final String status;
  final bool isConnected;

  const StatusIndicator({
    super.key,
    required this.status,
    required this.isConnected,
  });

  bool get _isSobrepeso => status.toLowerCase() == 'sobrepeso';

  @override
  Widget build(BuildContext context) {
    final color = !isConnected
        ? Colors.grey
        : _isSobrepeso
            ? AppColors.sobrepeso
            : AppColors.esquerda;

    final label = !isConnected
        ? 'Sem conexão'
        : _isSobrepeso
            ? 'SOBREPESO!'
            : 'Normal';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
