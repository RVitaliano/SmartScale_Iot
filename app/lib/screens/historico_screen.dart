import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      appBar: AppBar(
        title: const Text('Histórico de Pesagens',
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

            if (provider.historico.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhuma leitura registrada ainda.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    '${provider.historico.length} leituras',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: WeightLineChart(data: provider.historico),
                  ),
                ),
                const Divider(color: Colors.white12),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.historico.length,
                    itemBuilder: (_, i) =>
                        PesagemListTile(pesagem: provider.historico[i]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
