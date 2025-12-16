import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/auth_service.dart';

class EndDrawerWidget extends StatelessWidget {
  const EndDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final String currentUserEmail = user?.email ?? '';

    return Drawer(
      backgroundColor: AppTheme.primaryBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.primaryText,
                  size: 24.0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              
              // Title "Menu"
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  'Menu',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryText,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 30.0),

              // Menu Items
              _buildMenuItem(
                context,
                iconPath: 'assets/images/vnimc_1.png',
                label: 'Home / cardápio',
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/home');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/3a9k2_3.png',
                label: 'Perfil',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/profile');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/49svh_2.png',
                label: 'Pedidos',
                onTap: () {
                  Navigator.of(context).pop();
                  // Navigate to orders (shows both cart and order history)
                  context.push('/orders');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/fijek_4.png',
                label: 'Feedback',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/feedback');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/2emqy_5.png',
                label: 'Perguntas frequentes',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/faq');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/dfjsb_6.png',
                label: 'SAC',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/sac');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/x7hc1_7.png',
                label: 'Mapas e Direções',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/maps');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/k7eg7_8.png',
                label: 'Galeria de imagens',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/gallery');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/nswz3_9.png',
                label: 'Reservas pelo site',
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement redirect to reservation site
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Em breve!')),
                  );
                },
              ),

              const Divider(thickness: 2.0),

              // Admin Button - temporariamente habilitado para todos
              // TODO: Restaurar condição: if (currentUserEmail == 'hoteldunamys25@gmail.com' || currentUserEmail == 'rafaelhalder@gmail.com')
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/admin');
                  },
                  child: Container(
                    width: 130.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBackground,
                      borderRadius: BorderRadius.circular(65.0),
                      border: Border.all(
                        color: AppTheme.primaryText,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Administrador',
                        style: GoogleFonts.inter(
                          color: AppTheme.primaryText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
                
              const Spacer(),
              
              // Logout Button
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: InkWell(
                    onTap: () async {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        context.go('/login');
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: AppTheme.error),
                          const SizedBox(width: 8.0),
                          Text(
                            'Sair',
                            style: GoogleFonts.poppins(
                              color: AppTheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required String iconPath, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 40.0,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  width: 28.0,
                  height: 28.0,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.menu,
                    size: 24,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryText,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
