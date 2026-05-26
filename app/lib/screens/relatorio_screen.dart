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
    await context.read<SmartScaleProvider>().fetchSobrepesoLog();
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
            child: pw.Text('SmartScale — Relatório de Sobrepeso',
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text('Gerado em: $now',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 16),
          pw.Text('Total de ocorrências: ${eventos.length}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: ['Data/Hora', 'Peso (kg)'],
            data: eventos.map((e) => [
              fmt.format(e.timestamp.toLocal()),
              e.pesoKg.toStringAsFixed(2),
            ]).toList(),
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
      appBar: AppBar(
        title: const Text('Relatório de Sobrepeso',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Consumer<SmartScaleProvider>(
          builder: (context, provider, _) {
            if (_loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final eventos = provider.sobrepesoLog;
            final historico = provider.historico;
            final pesoMax = historico.isEmpty
                ? 0.0
                : historico
                    .map((e) => e.pesoKg)
                    .reduce((a, b) => a > b ? a : b);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Card
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resumo',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 16),
                        _summaryRow(
                            Icons.list, 'Total de pesagens', '${historico.length}'),
                        _summaryRow(
                            Icons.warning_amber_rounded,
                            'Ocorrências de sobrepeso',
                            '${eventos.length}',
                            color: eventos.isNotEmpty
                                ? AppColors.sobrepeso
                                : null),
                        _summaryRow(
                            Icons.arrow_upward,
                            'Peso máximo registrado',
                            '${pesoMax.toStringAsFixed(2)} kg',
                            color: pesoMax > 5.0
                                ? AppColors.sobrepeso
                                : null),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Ocorrências de Sobrepeso',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                if (eventos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                        child: Text('Nenhuma ocorrência registrada.',
                            style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...eventos.map((e) => _OverweightEventTile(pesagem: e)),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<SmartScaleProvider>(
        builder: (_, provider, __) => FloatingActionButton.extended(
          onPressed: provider.sobrepesoLog.isEmpty
              ? null
              : () => _exportPdf(provider.sobrepesoLog),
          backgroundColor: AppColors.sobrepeso,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Exportar PDF'),
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.grey))),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.white)),
        ],
      ),
    );
  }
}

class _OverweightEventTile extends StatelessWidget {
  final PesagemModel pesagem;

  const _OverweightEventTile({required this.pesagem});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm:ss');
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x33C62828),
          child: Icon(Icons.warning_amber_rounded,
              color: AppColors.sobrepeso, size: 20),
        ),
        title: Text('${pesagem.pesoKg.toStringAsFixed(2)} kg',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.sobrepeso)),
        subtitle: Text(
          fmt.format(pesagem.timestamp.toLocal()),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}
