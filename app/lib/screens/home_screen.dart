import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_colors.dart';
import '../models/pesagem_model.dart';
import '../providers/smartscale_provider.dart';
import '../widgets/weight_card.dart';
import '../widgets/overweight_banner.dart';
import '../widgets/classification_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime _sessionStart = DateTime.now();
  String? _lastError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SmartScaleProvider>().fetchHistorico();
    });
  }

  String _formatUptime(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SmartScaleProvider>(
      builder: (context, provider, _) {
        if (provider.error != null && provider.error != _lastError) {
          _lastError = provider.error;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.error!),
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          });
        }

        final isSobrepeso = provider.status.toLowerCase() == 'sobrepeso';
        final uptime = _formatUptime(DateTime.now().difference(_sessionStart));
        final recentReadings = provider.historico.take(3).toList();

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                // AppBar customizada
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      const Text(
                        'SmartScale',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: provider.isConnected
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.gray.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: provider.isConnected
                                ? AppColors.success.withValues(alpha: 0.40)
                                : AppColors.gray.withValues(alpha: 0.40),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              provider.isConnected
                                  ? Icons.wifi
                                  : Icons.wifi_off,
                              size: 14,
                              color: provider.isConnected
                                  ? AppColors.success
                                  : AppColors.gray,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              provider.isConnected ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: provider.isConnected
                                    ? AppColors.success
                                    : AppColors.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                OverweightBanner(visible: isSobrepeso),

                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryMid,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          child: Column(
                            children: [
                              WeightCard(
                                pesoKg: provider.pesoAtual,
                                classificacao: provider.classificacao,
                              ),
                              const SizedBox(height: 12),
                              _TelemetryStrip(uptime: uptime),
                              const SizedBox(height: 12),
                              _RecentEventsCard(readings: recentReadings),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Telemetry Strip ────────────────────────────────────────────────────────

class _TelemetryStrip extends StatelessWidget {
  final String uptime;

  const _TelemetryStrip({required this.uptime});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Cell(label: 'LIMITE', value: '4,0 kg'),
            _Divider(),
            _Cell(label: 'SENSOR', value: 'HX711'),
            _Divider(),
            _Cell(label: 'UPTIME', value: uptime),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String label;
  final String value;

  const _Cell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.onSurfaceDim,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppColors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: AppColors.outline,
    );
  }
}

// ─── Recent Events ────────────────────────────────────────────────────────────

class _RecentEventsCard extends StatelessWidget {
  final List<PesagemModel> readings;

  const _RecentEventsCard({required this.readings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EVENTOS RECENTES',
            style: TextStyle(
              color: AppColors.onSurfaceDim,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          if (readings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Carregando histórico...',
                  style: TextStyle(
                      color: AppColors.onSurfaceDim, fontSize: 12),
                ),
              ),
            )
          else
            ...readings.map((r) => _RecentRow(pesagem: r)),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  final PesagemModel pesagem;

  const _RecentRow({required this.pesagem});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm:ss');
    final isSobrepeso = pesagem.pesoKg > 4.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineSoft)),
      ),
      child: Row(
        children: [
          Text(
            timeFmt.format(pesagem.timestamp.toLocal()),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: AppColors.onSurfaceDim,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${pesagem.pesoKg.toStringAsFixed(2)} kg',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
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
