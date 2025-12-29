import 'package:flutter/material.dart';

/// Constantes de couleurs pour l'application
/// Palette bleu clair et blanc inspirée d'un design minimaliste et moderne
class AppColors {
  // Couleurs principales - Palette bleu clair/blanc
  static const Color primary = Color(0xFF64B5F6); // Bleu clair (couleur principale)
  static const Color primaryDark = Color(0xFF42A5F5); // Bleu moyen
  static const Color primaryLight = Color(0xFF90CAF9); // Bleu très clair
  static const Color secondary = Color(0xFF81C784); // Vert clair
  static const Color accent = Color(0xFF4FC3F7); // Cyan clair
  
  // Couleurs de fond
  static const Color background = Color(0xFFF5F5F5); // Gris très clair
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  
  // Couleurs neutres
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);
  
  // Couleurs d'état
  static const Color success = Color(0xFF66BB6A);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFB74D);
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF212121); // Noir/gris foncé pour texte
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnLight = Color(0xFF424242);

    static Color? get secondaryDark => null; // Gris foncé pour texte sur fond clair
}

