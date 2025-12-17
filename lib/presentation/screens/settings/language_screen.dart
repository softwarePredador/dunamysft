import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/locale_provider.dart';

/// Tela para seleção de idioma do aplicativo
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_circle_left_sharp,
              color: AppTheme.amarelo, size: 35.0),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Text(
          'Idioma / Language',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
            color: AppTheme.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          final currentLocale = localeProvider.locale;
          final languages = LocaleProvider.availableLanguages;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecione o idioma do aplicativo',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select app language',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: AppTheme.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: languages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final language = languages[index];
                      final isSelected =
                          currentLocale.languageCode == language.code;

                      return _LanguageCard(
                        language: language,
                        isSelected: isSelected,
                        onTap: () async {
                          await localeProvider.setLocale(language.locale);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _getConfirmationMessage(language.code),
                                ),
                                backgroundColor: AppTheme.success,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getConfirmationMessage(String code) {
    switch (code) {
      case 'en':
        return 'Language changed to English';
      case 'es':
        return 'Idioma cambiado a Español';
      case 'pt':
      default:
        return 'Idioma alterado para Português';
    }
  }
}

class _LanguageCard extends StatelessWidget {
  final LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.amarelo.withValues(alpha: 0.1) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.amarelo : AppTheme.grayPaletteGray20,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Flag emoji
              Text(
                language.flag,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 16),
              // Language names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.nativeName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0,
                        color: isSelected
                            ? AppTheme.amarelo
                            : AppTheme.primaryText,
                      ),
                    ),
                    Text(
                      language.name,
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // Check icon
              if (isSelected)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.amarelo,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
