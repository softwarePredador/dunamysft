import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/menu_item_model.dart';
import '../../providers/menu_provider.dart';
import '../../providers/category_provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    // Load menu items and categories
    Future.microtask(() {
      context.read<MenuProvider>().loadMenuItems();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryBackground,
        elevation: 0,
        title: Text(
          'Cardápio',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          _buildCategoryFilter(),
          // Menu Items List
          Expanded(
            child: _buildMenuItemsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final categories = categoryProvider.categories;
        final selectedCategoryId = context.watch<MenuProvider>().selectedCategoryId;

        return Container(
          height: 60,
          color: AppTheme.secondaryBackground,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // "Todos" option
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: selectedCategoryId.isEmpty,
                    onSelected: (selected) {
                      if (selected) {
                        context.read<MenuProvider>().clearFilters();
                      }
                    },
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: selectedCategoryId.isEmpty
                          ? Colors.white
                          : AppTheme.primaryText,
                    ),
                  ),
                );
              }

              final category = categories[index - 1];
              final isSelected = selectedCategoryId == category.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<MenuProvider>().filterByCategory(category.id);
                    }
                  },
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryText,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuItemsList() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        if (menuProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (menuProvider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar cardápio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  menuProvider.error,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final menuItems = menuProvider.menuItems;

        if (menuItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_menu, size: 64, color: AppTheme.grayPaletteGray60),
                const SizedBox(height: 16),
                Text(
                  'Nenhum item encontrado',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return _MenuItemCard(item: item);
          },
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Digite o nome do item...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            context.read<MenuProvider>().searchMenuItems(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<MenuProvider>().clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to item details
          context.push('/item-details', extra: item);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (item.photo.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  item.photo,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: AppTheme.grayPaletteGray20,
                      child: const Icon(Icons.image, size: 64, color: AppTheme.grayPaletteGray60),
                    );
                  },
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      if (item.onSale)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PROMOÇÃO',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.onSale && item.price != item.salePrice)
                            Text(
                              'R\$ ${item.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppTheme.secondaryText,
                                  ),
                            ),
                          Text(
                            'R\$ ${item.effectivePrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.primaryColors,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      // Stock indicator
                      if (!item.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.disabled,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Indisponível',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      else if (item.quantity < 10)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Últimas unidades',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
