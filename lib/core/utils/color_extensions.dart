import 'package:flutter/material.dart';

/// Extension para substituir withOpacity deprecated por withValues
extension ColorOpacity on Color {
  /// Retorna uma nova cor com a opacidade especificada (0.0 a 1.0)
  /// Usa withValues() ao invés de withOpacity() deprecated
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity);
  }
}
