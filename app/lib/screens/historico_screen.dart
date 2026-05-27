import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_colors.dart';
import '../providers/smartscale_provider.dart';
import '../widgets/weight_line_chart.dart';
import '../widgets/pesagem_list_tile.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await context.read<SmartScaleProvider>().fetchHistorico();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: const [
                  Text(
                    'Histórico',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryMid,
                backgroundColor: AppColors.surfaceCard,
                onRefresh: _load,
                child: Consumer<SmartScaleProvider>(
                  builder: (context, provider, _) {
                    if (_loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryMid),
                      );
                    }

                    final historico = provider.historico;
                    final sobrepesoCount =
                        historico.where((e) => e.pesoKg > 5.0).length;
                    final maxPeso = historico.isEmpty
                        ? 0.0
                        : historico
                            .map((e) => e.pesoKg)
                            .reduce((a, b) => a > b ? a : b);

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        // Mini stats row
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStatCard(
                                label: 'LEITURAS',
                                value: '${historico.length}',
                                icon: Icons.list_alt_rounded,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MiniStatCard(
                                label: 'SOBREPESOS',
                                value: '$sobrepesoCount',
                                icon: Icons.warning_amber_rounded,
                                isRed: sobrepesoCount > 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MiniStatCard(
                                label: 'MÁXIMO',
                                value:
                                    '${maxPeso.toStringAsFixed(2)} kg',
                                icon: Icons.arrow_upward_rounded,
                                isRed: maxPeso > 5.0,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Chart card
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 16, 16, 0),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Últimas 50 pesagens',
                                      style: TextStyle(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (historico.length >= 2)
                                      _TrendChip(historico: historico),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 200,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      4, 0, 12, 4),
                                  child:
                                      WeightLineChart(data: historico),
                                ),
                              ),
                              // Legenda
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 8, 16, 16),
                                child: Row(
                                  children: [
                                    _LegendDot(color: AppColors.primaryMid),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Peso (kg)',
                                      style: TextStyle(
                                          color: AppColors.onSurfaceMuted,
                                          fontSize: 11),
                                    ),
                                    const SizedBox(width: 16),
                                    _LegendDash(color: AppColors.danger),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Limite 5,0 kg',
                                      style: TextStyle(
                                          color: AppColors.onSurfaceMuted,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // List header
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              const Text(
                                'Todas as leituras',
                                style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.filter_list,
                                    size: 14,
                                    color: AppColors.onSurfaceDim),
                                label: const Text(
                                  'FILTRAR',
                                  style: TextStyle(
                                    color: AppColors.onSurfaceDim,
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Readings list
                        if (historico.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'Nenhuma leitura registrada ainda.',
                                style:
                                    TextStyle(color: AppColors.onSurfaceDim),
                              ),
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: Column(
                              children: [
                                for (final p in historico)
                                  PesagemListTile(pesagem: p),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mini Stat Card ───────────────────────────────────────────────────────────

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isRed;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRed ? AppColors.danger : AppColors.primaryMid;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurfaceDim,
              fontSize: 9,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trend Chip ──────────────────────────────────────────────────────────────

class _TrendChip extends StatelessWidget {
  final List historico;

  const _TrendChip({required this.historico});

  @override
  Widget build(BuildContext context) {
    final delta =
        (historico[0].pesoKg as double) - (historico[1].pesoKg as double);
    final isUp = delta >= 0;
    final color = isUp ? AppColors.danger : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            '${delta.abs().toStringAsFixed(2)} kg',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Legend items ─────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _LegendDash extends StatelessWidget {
  final Color color;

  const _LegendDash({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 2, color: color),
        const SizedBox(width: 2),
        Container(width: 6, height: 2, color: color),
        const SizedBox(width: 2),
        Container(width: 6, height: 2, color: color),
      ],
    );
  }
}
