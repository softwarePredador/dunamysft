import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/assets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppAssets.loginImage,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              opacity: const AlwaysStoppedAnimation(0.7),
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.28],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Top Section (Logo & Welcome Text)
                SizedBox(
                  height: size.height * 0.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: Image.asset(
                          AppAssets.loginLogo,
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 15.0, 24.0, 0.0),
                        child: Text(
                          'Olá, seja bem-vindo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 30.0,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryText.withOpacity(0.8),
                          ),
                        ),
                      ),
                      Text(
                        'Por favor, selecione uma das opções',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: AppTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Section (Buttons)
                Container(
                  height: size.height * 0.50,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Button
                      SizedBox(
                        width: 320.0,
                        height: 90.0,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final authService = Provider.of<AuthService>(context, listen: false);
                            final user = await authService.signInWithGoogle();
                            if (user != null && context.mounted) {
                              context.go('/home');
                            }
                          },
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: FaIcon(FontAwesomeIcons.google, size: 37.0),
                          ),
                          label: Text(
                            'Entrar com Google',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryText,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: AppTheme.primaryText, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Apple Button
                      if (!Platform.isAndroid) 
                        SizedBox(
                          width: 320.0,
                          height: 90.0,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                               final authService = Provider.of<AuthService>(context, listen: false);
                               final user = await authService.signInWithApple();
                               if (user != null && context.mounted) {
                                 context.go('/home');
                               }
                            },
                            icon: const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Icon(Icons.apple, size: 45.0),
                            ),
                            label: Text(
                              'Entrar com Apple',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryText,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: AppTheme.primaryText, width: 2),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
