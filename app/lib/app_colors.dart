import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0F1117);
  static const surfaceCard = Color(0xFF1A1D27);
  static const surfaceHigh = Color(0xFF22263A);
  static const outline = Color(0xFF2E3350);
  static const outlineSoft = Color(0xFF1E2238);
  static const primaryMid = Color(0xFF1E88E5);
  static const success = Color(0xFF2E7D32);
  static const danger = Color(0xFFC62828);
  static const dangerSoft = Color(0x1FC62828);
  static const gray = Color(0xFF546E7A);
  static const onSurface = Color(0xFFE8EAF6);
  static const onSurfaceMuted = Color(0xFF9098B8);
  static const onSurfaceDim = Color(0xFF5C6480);

  // Aliases usados em main.dart e código legado
  static const background = bg;
  static const surface = surfaceCard;
  static const esquerda = success;
  static const direita = primaryMid;
  static const sobrepeso = danger;
  static const vazio = gray;

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
