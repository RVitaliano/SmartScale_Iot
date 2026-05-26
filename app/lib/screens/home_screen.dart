import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/smartscale_provider.dart';
import '../widgets/weight_card.dart';
import '../widgets/classification_badge.dart';
import '../widgets/status_indicator.dart';
import '../widgets/overweight_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _lastError;

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
                  backgroundColor: Colors.red[800],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        }

        final isSobrepeso = provider.status.toLowerCase() == 'sobrepeso';
        final fmt = DateFormat('HH:mm:ss dd/MM/yyyy');

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'SmartScale',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  provider.isConnected
                      ? Icons.wifi
                      : Icons.wifi_off,
                  color: provider.isConnected ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    OverweightBanner(visible: isSobrepeso),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            WeightCard(
                              pesoKg: provider.pesoAtual,
                              classificacao: provider.classificacao,
                            ),
                            const SizedBox(height: 24),
                            StatusIndicator(
                              status: provider.status,
                              isConnected: provider.isConnected,
                            ),
                            const SizedBox(height: 16),
                            ClassificationBadge(
                                classificacao: provider.classificacao),
                            const SizedBox(height: 24),
                            if (provider.ultimaAtualizacao != null)
                              Text(
                                'Última atualização: ${fmt.format(provider.ultimaAtualizacao!.toLocal())}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              'Atualizando a cada 5 segundos',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
