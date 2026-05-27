import 'package:flutter/material.dart';
import '../models/pesagem_model.dart';
import '../app_colors.dart';

class WeightLineChart extends StatelessWidget {
  final List<PesagemModel> data;

  const WeightLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma leitura registrada ainda.',
          style: TextStyle(color: AppColors.onSurfaceDim),
        ),
      );
    }
    return CustomPaint(
      painter: _ChartPainter(data: data),
      child: const SizedBox.expand(),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<PesagemModel> data;

  static const double _maxY = 6.0;
  static const double _limitY = 5.0;

  _ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 42.0;
    const padR = 14.0;
    const padT = 12.0;
    const padB = 24.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;

    // Oldest on left, newest on right
    final pts = List<PesagemModel>.from(data.reversed);
    final n = pts.length;

    double toX(int i) => padL + (n > 1 ? (i / (n - 1)) * w : w / 2);
    double toY(double kg) => padT + h * (1 - (kg / _maxY).clamp(0.0, 1.0));

    // Y grid + labels
    final labelStyle = const TextStyle(
      color: AppColors.onSurfaceDim,
      fontSize: 9,
    );
    for (final kg in [0.0, 2.0, 4.0, 6.0]) {
      final y = toY(kg);
      final tp = TextPainter(
        text: TextSpan(text: '${kg.toStringAsFixed(0)}', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(padL - tp.width - 4, y - tp.height / 2));
      canvas.drawLine(
        Offset(padL, y),
        Offset(padL + w, y),
        Paint()
          ..color = AppColors.outlineSoft
          ..strokeWidth = 0.5,
      );
    }

    if (n < 2) {
      if (n == 1) {
        canvas.drawCircle(
          Offset(toX(0), toY(pts[0].pesoKg)),
          4,
          Paint()..color = AppColors.primaryMid,
        );
      }
      return;
    }

    final offsets = List.generate(n, (i) => Offset(toX(i), toY(pts[i].pesoKg)));

    // Gradient area
    final gradPath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final o in offsets.skip(1)) {
      gradPath.lineTo(o.dx, o.dy);
    }
    gradPath
      ..lineTo(offsets.last.dx, padT + h)
      ..lineTo(offsets.first.dx, padT + h)
      ..close();

    canvas.drawPath(
      gradPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryMid.withValues(alpha: 0.20),
            AppColors.primaryMid.withValues(alpha: 0.00),
          ],
        ).createShader(Rect.fromLTWH(0, padT, size.width, h)),
    );

    // Line segments — blue below limit, red above
    for (var i = 0; i < n - 1; i++) {
      final v1 = pts[i].pesoKg;
      final v2 = pts[i + 1].pesoKg;
      final aboveLimit = v1 > _limitY && v2 > _limitY;
      canvas.drawLine(
        offsets[i],
        offsets[i + 1],
        Paint()
          ..color = aboveLimit ? AppColors.danger : AppColors.primaryMid
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // Dashed limit line
    final limitY = toY(_limitY);
    double dashX = padL;
    final dashPaint = Paint()
      ..color = AppColors.danger
      ..strokeWidth = 1.5;
    while (dashX < padL + w - 6) {
      canvas.drawLine(Offset(dashX, limitY), Offset(dashX + 6, limitY), dashPaint);
      dashX += 11;
    }

    // "LIMITE" label box
    final limitLabel = TextPainter(
      text: const TextSpan(
        text: 'LIMITE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final boxW = limitLabel.width + 8;
    const boxH = 16.0;
    final boxL = padL + w - boxW - 2;
    final boxT = limitY - boxH / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(boxL, boxT, boxW, boxH),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.danger,
    );
    limitLabel.paint(canvas, Offset(boxL + 4, boxT + (boxH - limitLabel.height) / 2));

    // Data points
    for (var i = 0; i < n; i++) {
      final isSobrepeso = pts[i].pesoKg > _limitY;
      final isLast = i == n - 1;
      if (!isSobrepeso && !isLast) continue;
      final dotColor = isSobrepeso ? AppColors.danger : AppColors.primaryMid;
      final r = isLast ? 5.0 : 4.0;
      canvas.drawCircle(offsets[i], r, Paint()..color = dotColor);
      canvas.drawCircle(
        offsets[i],
        r,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.data != data;
}
