class PesagemModel {
  final double pesoKg;
  final String classificacao;
  final String status;
  final DateTime timestamp;

  const PesagemModel({
    required this.pesoKg,
    required this.classificacao,
    required this.status,
    required this.timestamp,
  });

  factory PesagemModel.fromJson(Map<String, dynamic> json) {
    return PesagemModel(
      pesoKg: (json['value'] as num).toDouble(),
      classificacao: json['metadata']?['classificacao'] ?? _classificarPeso((json['value'] as num).toDouble()),
      status: json['metadata']?['status'] ?? _statusDePeso((json['value'] as num).toDouble()),
      timestamp: DateTime.parse(json['time'] as String),
    );
  }

  static String _classificarPeso(double peso) {
    if (peso < 0.05) return 'VAZIO';
    if (peso <= 2.0) return 'ESQUERDA';
    if (peso <= 4.0) return 'DIREITA';
    return 'SOBREPESO';
  }

  static String _statusDePeso(double peso) {
    return peso > 4.0 ? 'sobrepeso' : 'ok';
  }
}
