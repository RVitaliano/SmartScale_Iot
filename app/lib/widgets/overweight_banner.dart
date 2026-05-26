import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';

class OverweightBanner extends StatefulWidget {
  final bool visible;

  const OverweightBanner({super.key, required this.visible});

  @override
  State<OverweightBanner> createState() => _OverweightBannerState();
}

class _OverweightBannerState extends State<OverweightBanner> {
  bool _triggered = false;

  @override
  void didUpdateWidget(OverweightBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      HapticFeedback.heavyImpact();
      _triggered = true;
    } else if (!widget.visible) {
      _triggered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: AppColors.sobrepeso,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'SOBREPESO DETECTADO!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
