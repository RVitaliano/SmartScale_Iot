import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../app_colors.dart';
import '../models/pesagem_model.dart';
import '../providers/smartscale_provider.dart';

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({super.key});

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final provider = context.read<SmartScaleProvider>();
    await Future.wait([
      provider.fetchSobrepesoLog(),
      provider.fetchHistorico(),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _exportPdf(List<PesagemModel> eventos) async {
    final pdf = pw.Document();
    final fmt = DateFormat('dd/MM/yyyy HH:mm:ss');
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'SmartScale — Relatório de Sobrepeso',
              style: pw.TextStyle(
                  fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text('Gerado em: $now',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 16),
          pw.Text('Total de ocorrências: ${eventos.length}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['Data/Hora', 'Peso (kg)'],
            data: eventos
                .map((e) => [
                      fmt.format(e.timestamp.toLocal()),
                      e.pesoKg.toStringAsFixed(2),
                    ])
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            border: pw.TableBorder.all(color: PdfColors.grey400),
          ),
          pw.Footer(
            trailing: pw.Text('SmartScale — Faculdade Nova Roma',
                style: const pw.TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'smartscale_sobrepeso_$now.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: const [
                  Text(
                    'Relatório',
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
                    final eventos = provider.sobrepesoLog;
                    final maxPeso = historico.isEmpty
                        ? 0.0
                        : historico
                            .map((e) => e.pesoKg)
                            .reduce((a, b) => a > b ? a : b);
                    final avgPeso = historico.isEmpty
                        ? 0.0
                        : historico.map((e) => e.pesoKg).reduce((a, b) => a + b) /
                            historico.length;

                    return ListView(
                      padding:
                          const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      children: [
                        // Período card
                        _PeriodCard(),

                        const SizedBox(height: 12),

                        // 2x2 Summary grid
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.4,
                          children: [
                            _SummaryCard(
                              label: 'TOTAL DE PESAGENS',
                              value: '${historico.length}',
                              suffix: '',
                              icon: Icons.list_alt_rounded,
                              color: AppColors.primaryMid,
                            ),
                            _SummaryCard(
                              label: 'SOBREPESOS',
                              value: '${eventos.length}',
                              suffix: '',
                              icon: Icons.warning_amber_rounded,
                              color: AppColors.danger,
                              hasDangerBg: true,
                            ),
                            _SummaryCard(
                              label: 'PESO MÁXIMO',
                              value: maxPeso.toStringAsFixed(2),
                              suffix: 'kg',
                              icon: Icons.arrow_upward_rounded,
                              color: maxPeso > 4.0
                                  ? AppColors.danger
                                  : AppColors.primaryMid,
                            ),
                            _SummaryCard(
                              label: 'PESO MÉDIO',
                              value: avgPeso.toStringAsFixed(2),
                              suffix: 'kg',
                              icon: Icons.bar_chart_rounded,
                              color: AppColors.primaryMid,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Occurrences header
                        Row(
                          children: [
                            const Text(
                              'Ocorrências de sobrepeso',
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.dangerSoft,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: AppColors.danger
                                        .withValues(alpha: 0.30)),
                              ),
                              child: Text(
                                '${eventos.length}',
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Occurrences list
                        if (eventos.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: const Center(
                              child: Text(
                                'Nenhuma ocorrência registrada.',
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
                                for (final e in eventos)
                                  _OverweightEventTile(pesagem: e),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Export hint box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.outline,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.download_rounded,
                                  color: AppColors.onSurfaceDim, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Toque no botão abaixo para gerar um PDF com todas as ocorrências de sobrepeso.',
                                  style: TextStyle(
                                    color: AppColors.onSurfaceDim,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
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
      floatingActionButton: Consumer<SmartScaleProvider>(
        builder: (_, provider, __) => FloatingActionButton.extended(
          onPressed: provider.sobrepesoLog.isEmpty
              ? null
              : () => _exportPdf(provider.sobrepesoLog),
          backgroundColor: AppColors.primaryMid,
          disabledElevation: 0,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text(
            'Exportar PDF',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// ─── Period Card ──────────────────────────────────────────────────────────────

class _PeriodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 14, color: AppColors.onSurfaceDim),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PERÍODO DO RELATÓRIO',
                style: TextStyle(
                  color: AppColors.onSurfaceDim,
                  fontSize: 9,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateFmt.format(DateTime.now()),
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryMid.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  color: AppColors.primaryMid.withValues(alpha: 0.30)),
            ),
            child: const Text(
              'HOJE',
              style: TextStyle(
                color: AppColors.primaryMid,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final IconData icon;
  final Color color;
  final bool hasDangerBg;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.color,
    this.hasDangerBg = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasDangerBg
            ? AppColors.dangerSoft
            : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasDangerBg
              ? AppColors.danger.withValues(alpha: 0.25)
              : AppColors.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (suffix.isNotEmpty)
                  TextSpan(
                    text: ' $suffix',
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.70),
                    ),
                  ),
              ],
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

// ─── Overweight Event Tile ───────────────────────────────────────────────────

class _OverweightEventTile extends StatelessWidget {
  final PesagemModel pesagem;

  const _OverweightEventTile({required this.pesagem});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm:ss');
    final excess = pesagem.pesoKg - 4.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineSoft)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.danger,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pesagem.pesoKg.toStringAsFixed(2)} kg',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fmt.format(pesagem.timestamp.toLocal()),
                  style: const TextStyle(
                    color: AppColors.onSurfaceDim,
                    fontSize: 11,
                  ),
                ),
                if (excess > 0)
                  Text(
                    '+${excess.toStringAsFixed(2)} kg acima do limite',
                    style: const TextStyle(
                      color: AppColors.onSurfaceDim,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.30)),
            ),
            child: const Text(
              'SOBREPESO',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
