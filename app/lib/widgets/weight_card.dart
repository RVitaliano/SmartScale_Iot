import 'dart:math';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'classification_badge.dart';

class WeightCard extends StatelessWidget {
  final double pesoKg;
  final String classificacao;

  const WeightCard({
    super.key,
    required this.pesoKg,
    required this.classificacao,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromClassificacao(classificacao);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _WeightRingPainter(
                    progress: (pesoKg / 5.0).clamp(0.0, 1.2),
                    color: color,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _WeightDisplay(peso: pesoKg),
                    const SizedBox(height: 10),
                    ClassificationBadge(classificacao: classificacao),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightDisplay extends StatelessWidget {
  final double peso;

  const _WeightDisplay({required this.peso});

  @override
  Widget build(BuildContext context) {
    final str = peso.toStringAsFixed(2);
    final parts = str.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '00';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: intPart,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
              height: 1.0,
            ),
          ),
          TextSpan(
            text: '.$decPart',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 36,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceMuted,
              height: 1.0,
            ),
          ),
          const TextSpan(
            text: ' kg',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _WeightRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const startAngle = pi * 0.75;
    const sweepTotal = pi * 1.5;

    // Track background
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..color = AppColors.outlineSoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    final sweep = sweepTotal * progress.clamp(0.0, 1.0);

    // Glow layer
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Active arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_WeightRingPainter old) =>
      old.progress != progress || old.color != color;
}
