import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Widget contador de quantidade com botões + e -
class QuantityCounterWidget extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;

  const QuantityCounterWidget({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.alternate,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement Button
          IconButton(
            onPressed: quantity > minValue
                ? () => onChanged(quantity - 1)
                : null,
            icon: FaIcon(
              FontAwesomeIcons.minus,
              color: quantity > minValue
                  ? AppTheme.secondaryText
                  : const Color(0xFFE0E3E7),
              size: 10,
            ),
          ),
          // Count Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.amarelo,
              ),
            ),
          ),
          // Increment Button
          IconButton(
            onPressed: quantity < maxValue
                ? () => onChanged(quantity + 1)
                : null,
            icon: FaIcon(
              FontAwesomeIcons.plus,
              color: quantity < maxValue
                  ? AppTheme.primaryText
                  : const Color(0xFFE0E3E7),
              size: 10,
            ),
          ),
        ],
      ),
    );
  }
}
