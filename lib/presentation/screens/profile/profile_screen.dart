import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 64, color: AppTheme.grayPaletteGray60),
              const SizedBox(height: 16),
              const Text('Faça login para ver seu perfil'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Fazer Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.055),
        child: AppBar(
          backgroundColor: AppTheme.primaryBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_circle_left_sharp,
              color: AppTheme.amarelo,
              size: 35.0,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: const Text('Meu Perfil'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              tooltip: 'Sair',
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppTheme.secondaryBackground,
              child: Column(
                children: [
                  if (user.photoURL != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.photoURL!),
                    )
                  else
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primary,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName ?? 'Usuário',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryText,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Menu Items
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _ProfileMenuItem(
          icon: Icons.shopping_bag_outlined,
          title: 'Meus Pedidos',
          onTap: () => context.go('/orders'),
        ),
        _ProfileMenuItem(
          icon: Icons.shopping_cart_outlined,
          title: 'Carrinho',
          onTap: () => context.go('/cart'),
        ),
        _ProfileMenuItem(
          icon: Icons.restaurant_menu,
          title: 'Cardápio',
          onTap: () => context.go('/home'),
        ),
        const Divider(height: 1),
        _ProfileMenuItem(
          icon: Icons.help_outline,
          title: 'Perguntas Frequentes',
          onTap: () => context.go('/faq'),
        ),
        _ProfileMenuItem(
          icon: Icons.feedback_outlined,
          title: 'Enviar Feedback',
          onTap: () {
            // Navigate to feedback screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tela de feedback em desenvolvimento')),
            );
          },
        ),
        const Divider(height: 1),
        _ProfileMenuItem(
          icon: Icons.info_outline,
          title: 'Sobre',
          onTap: () {
            _showAboutDialog(context);
          },
        ),
        _ProfileMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Política de Privacidade',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Política de privacidade em desenvolvimento')),
            );
          },
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hotel Dunamys'),
            const SizedBox(height: 8),
            const Text('Versão 1.0.0'),
            const SizedBox(height: 16),
            Text(
              'Aplicativo desenvolvido para gerenciar pedidos e serviços do Hotel Dunamys.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryText),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
      onTap: onTap,
    );
  }
}
