import 'package:flutter/material.dart';

class AppColors {
  static const vazio = Color(0xFF9E9E9E);
  static const esquerda = Color(0xFF2E7D32);
  static const direita = Color(0xFF1565C0);
  static const sobrepeso = Color(0xFFC62828);
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const onSurface = Color(0xFFE0E0E0);

  static Color fromClassificacao(String classificacao) {
    switch (classificacao.toUpperCase()) {
      case 'ESQUERDA':
        return esquerda;
      case 'DIREITA':
        return direita;
      case 'SOBREPESO':
        return sobrepeso;
      default:
        return vazio;
    }
  }
}
