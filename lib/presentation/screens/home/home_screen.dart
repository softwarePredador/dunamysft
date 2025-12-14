import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';

/// Home screen demonstrating Clean Architecture
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppTheme.primaryText,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: AppStrings.logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (user?.photoURL != null)
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(user!.photoURL!),
                      )
                    else
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Bem-vindo!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.displayName ?? user?.email ?? 'Visitante',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Action Cards
            _ActionCard(
              icon: Icons.restaurant_menu,
              title: 'Cardápio',
              description: 'Veja nosso cardápio e faça seu pedido',
              onTap: () => context.go('/menu'),
            ),
            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.hotel,
              title: AppStrings.availableRooms,
              description: 'Veja os quartos disponíveis',
              onTap: () => _showPlaceholder(context, 'Tela de quartos'),
            ),
            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.calendar_today,
              title: AppStrings.myReservations,
              description: 'Gerencie suas reservas',
              onTap: () => context.go('/orders'),
            ),
            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.shopping_cart,
              title: 'Carrinho',
              description: 'Ver itens no carrinho',
              onTap: () => context.go('/cart'),
            ),
            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.person,
              title: AppStrings.profile,
              description: 'Edite seu perfil',
              onTap: () => context.go('/profile'),
            ),

            const SizedBox(height: 32),

            // Architecture Info
            Card(
              color: AppTheme.primaryText.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.architecture,
                      size: 48,
                      color: AppTheme.primaryText,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Clean Architecture',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Este projeto segue os princípios de Clean Architecture, garantindo código manutenível, testável e escalável.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action card widget for the home screen
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryText.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows placeholder message for screens in development
void _showPlaceholder(BuildContext context, String screenName) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$screenName em desenvolvimento'),
      duration: const Duration(seconds: 2),
    ),
  );
}

