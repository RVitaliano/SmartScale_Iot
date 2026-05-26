import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/pesagem_model.dart';
import '../services/tago_service.dart';

class SmartScaleProvider extends ChangeNotifier {
  final _service = TagoIOService();

  double pesoAtual = 0.0;
  String classificacao = 'VAZIO';
  String status = 'ok';
  bool isLoading = true;
  bool isConnected = false;
  String? error;
  List<PesagemModel> historico = [];
  List<PesagemModel> sobrepesoLog = [];

  DateTime? ultimaAtualizacao;
  Timer? _timer;

  SmartScaleProvider() {
    _startPolling();
  }

  void _startPolling() {
    _fetchNow();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchNow());
  }

  Future<void> _fetchNow() async {
    try {
      final peso = await _service.getPesoAtual();
      final classif = await _service.getClassificacao();
      final st = await _service.getStatus();

      pesoAtual = peso;
      classificacao = classif;
      status = st;
      ultimaAtualizacao = DateTime.now();
      isConnected = true;
      error = null;
    } on TagoAuthException {
      error = 'Erro de autenticação TagoIO. Verifique o token.';
      isConnected = false;
    } on TagoServerException {
      error = 'Serviço indisponível. Últimos dados exibidos.';
      isConnected = false;
    } on TimeoutException {
      error = 'Tempo esgotado. Tentando novamente...';
      isConnected = false;
    } catch (_) {
      error = 'Sem conexão. Tentando novamente...';
      isConnected = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistorico() async {
    try {
      historico = await _service.getHistorico(50);
      error = null;
    } on TagoAuthException {
      error = 'Erro de autenticação TagoIO. Verifique o token.';
    } on TagoServerException {
      error = 'Serviço indisponível.';
    } catch (_) {
      error = 'Sem conexão.';
    }
    notifyListeners();
  }

  Future<void> fetchSobrepesoLog() async {
    try {
      sobrepesoLog = await _service.getSobrepesoLog();
      error = null;
    } on TagoAuthException {
      error = 'Erro de autenticação TagoIO. Verifique o token.';
    } on TagoServerException {
      error = 'Serviço indisponível.';
    } catch (_) {
      error = 'Sem conexão.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
