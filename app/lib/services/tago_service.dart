import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pesagem_model.dart';

class TagoIOService {
  static const _baseUrl = 'https://api.tago.io/data';
  static const _token = String.fromEnvironment('TAGO_TOKEN');

  static Map<String, String> get _headers => {
        'Authorization': _token,
        'Content-Type': 'application/json',
      };

  Future<double> getPesoAtual() async {
    final uri = Uri.parse('$_baseUrl?variable=peso_kg&qty=1');
    final response = await http.get(uri, headers: _headers).timeout(
      const Duration(seconds: 10),
    );
    _checkStatus(response);
    final data = _parseResult(response.body);
    if (data.isEmpty) return 0.0;
    return (data.first['value'] as num).toDouble();
  }

  Future<String> getClassificacao() async {
    final uri = Uri.parse('$_baseUrl?variable=classificacao&qty=1');
    final response = await http.get(uri, headers: _headers).timeout(
      const Duration(seconds: 10),
    );
    _checkStatus(response);
    final data = _parseResult(response.body);
    if (data.isEmpty) return 'VAZIO';
    return data.first['value']?.toString().toUpperCase() ?? 'VAZIO';
  }

  Future<String> getStatus() async {
    final uri = Uri.parse('$_baseUrl?variable=status&qty=1');
    final response = await http.get(uri, headers: _headers).timeout(
      const Duration(seconds: 10),
    );
    _checkStatus(response);
    final data = _parseResult(response.body);
    if (data.isEmpty) return 'ok';
    return data.first['value']?.toString().toLowerCase() ?? 'ok';
  }

  Future<List<PesagemModel>> getHistorico(int qty) async {
    final uri = Uri.parse('$_baseUrl?variable=peso_kg&qty=$qty');
    final response = await http.get(uri, headers: _headers).timeout(
      const Duration(seconds: 10),
    );
    _checkStatus(response);
    final data = _parseResult(response.body);
    return data.map((e) => PesagemModel.fromJson(e)).toList();
  }

  Future<List<PesagemModel>> getSobrepesoLog() async {
    final uri = Uri.parse('$_baseUrl?variable=status&value=sobrepeso&qty=20');
    final response = await http.get(uri, headers: _headers).timeout(
      const Duration(seconds: 10),
    );
    _checkStatus(response);
    final data = _parseResult(response.body);
    return data.map((e) {
      final peso = (e['metadata']?['peso_kg'] as num?)?.toDouble() ?? 0.0;
      return PesagemModel(
        pesoKg: peso,
        classificacao: 'SOBREPESO',
        status: 'sobrepeso',
        timestamp: DateTime.parse(e['time'] as String),
      );
    }).toList();
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode == 401) {
      throw const TagoAuthException('Token inválido ou sem permissão.');
    }
    if (response.statusCode >= 500) {
      throw const TagoServerException('Serviço TagoIO indisponível.');
    }
    if (response.statusCode != 200) {
      throw TagoException('Erro HTTP ${response.statusCode}');
    }
  }

  List<dynamic> _parseResult(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    return (json['result'] as List?) ?? [];
  }
}

class TagoException implements Exception {
  final String message;
  const TagoException(this.message);
  @override
  String toString() => message;
}

class TagoAuthException extends TagoException {
  const TagoAuthException(super.message);
}

class TagoServerException extends TagoException {
  const TagoServerException(super.message);
}
