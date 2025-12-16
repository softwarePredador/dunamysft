import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'redirect_page_widget.dart';

class NavbarWidget extends StatelessWidget {
  final int pageIndex;
  final VoidCallback? onMenuTap;

  const NavbarWidget({super.key, this.pageIndex = 1, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Tamanhos proporcionais
    final navbarHeight = screenHeight * 0.14; // ~115 em tela 820
    final iconWidth = screenWidth * 0.2; // ~80 em tela 400
    final iconHeight = screenHeight * 0.073; // ~60 em tela 820
    final centerButtonSize = screenWidth * 0.16; // ~64 em tela 400
    final bgHeight = screenHeight * 0.091; // ~75 em tela 820

    return SizedBox(
      height: navbarHeight,
      child: Stack(
        children: [
          // Background SVG
          Align(
            alignment: const AlignmentDirectional(0.0, 1.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: SvgPicture.asset(
                'assets/images/navbar_4_bg_white.svg',
                width: double.infinity,
                height: bgHeight,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Navigation Items
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
            child: Container(
              width: double.infinity,
              height: 72.0,
              constraints: const BoxConstraints(minHeight: 76.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 14.0),

                  // Menu Item - Abre o EndDrawer (igual FlutterFlow)
                  Expanded(
                    flex: 2,
                    child: _NavbarItem(
                      imagePath: 'assets/images/login1_(2).png',
                      onTap: () {
                        // Tenta abrir o EndDrawer se disponível
                        if (onMenuTap != null) {
                          onMenuTap!();
                        } else {
                          // Fallback: tenta abrir via Scaffold
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold?.hasEndDrawer ?? false) {
                            scaffold!.openEndDrawer();
                          } else {
                            // Se não tiver drawer, navega para home e abre
                            context.go('/home');
                          }
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 8.0),

                  // Cart Item
                  Expanded(
                    flex: 2,
                    child: _NavbarItem(
                      imagePath: 'assets/images/Group_132.png',
                      onTap: () => context.push('/cart'),
                    ),
                  ),

                  const Spacer(flex: 3), // Space for the center button

                  const SizedBox(width: 8.0),

                  // Profile Item
                  Expanded(
                    flex: 2,
                    child: _NavbarItem(
                      imagePath: 'assets/images/Group_133.png',
                      onTap: () => context.push('/profile'),
                    ),
                  ),

                  const SizedBox(width: 8.0),

                  // More/Redirect Item
                  Expanded(
                    flex: 2,
                    child: _NavbarItem(
                      imagePath: 'assets/images/Group_134.png',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return Dialog(
                              elevation: 0,
                              insetPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              alignment: Alignment.center,
                              child: const SizedBox(
                                height: double.infinity,
                                width: double.infinity,
                                child: RedirectPageWidget(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14.0),
                ],
              ),
            ),
          ),

          // Center Floating Button (Home)
          Align(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: InkWell(
              onTap: () => context.go('/home'),
              child: Container(
                width: centerButtonSize,
                height: centerButtonSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.amareloGradientStart,
                      AppTheme.amareloGradientEnd,
                    ],
                    stops: const [0.5, 1.0],
                    begin: const AlignmentDirectional(0.0, -1.0),
                    end: const AlignmentDirectional(0, 1.0),
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/95z4v_s.png',
                    width: iconWidth,
                    height: iconHeight,
                    fit: BoxFit.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavbarItem extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _NavbarItem({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Tamanhos proporcionais
    final iconWidth = screenWidth * 0.2; // ~80 em tela 400
    final iconHeight = screenHeight * 0.073; // ~60 em tela 820

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              imagePath,
              width: iconWidth,
              height: iconHeight,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
