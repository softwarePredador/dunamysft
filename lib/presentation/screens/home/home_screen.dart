import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/gallery_item.dart';
import '../../../domain/entities/menu_item.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/home_provider.dart';

import '../../widgets/navbar_widget.dart';
import '../../widgets/end_drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Reset pedidoEmAndamento ao entrar na Home (igual FlutterFlow)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().pedidoEmAndamento = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: const EndDrawerWidget(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá!',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 18.0,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            Text(
                              user?.displayName ?? 'Visitante',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 18.0,
                                decoration: TextDecoration.underline,
                                color: AppTheme.primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: Text(
                              'Seu pedido',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.normal,
                                fontSize: 12.0,
                                color: AppTheme.primaryText,
                              ),
                            ),
                          ),
                          // Notification Bell com Badge
                          Consumer<AppStateProvider>(
                            builder: (context, appState, child) {
                              final hasPedido = appState.pedidoEmAndamento;

                              return InkWell(
                                onTap: () {
                                  // Navegar para tela de pedidos
                                  // Na nossa lógica, o quarto já foi informado antes do pagamento
                                  context.push('/orders');
                                },
                                child: hasPedido
                                    ? badges.Badge(
                                        badgeContent: const Text(
                                          ' ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 6,
                                          ),
                                        ),
                                        showBadge: true,
                                        badgeStyle: const badges.BadgeStyle(
                                          badgeColor: AppTheme.secondary,
                                          elevation: 4,
                                          padding: EdgeInsets.all(4),
                                        ),
                                        position:
                                            badges.BadgePosition.topStart(),
                                        badgeAnimation:
                                            const badges.BadgeAnimation.scale(),
                                        child: Image.asset(
                                          'assets/images/campainha.png',
                                          width: 23.0,
                                          height: 23.0,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.notifications_none,
                                                    size: 24,
                                                  ),
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/images/campainha.png',
                                        width: 23.0,
                                        height: 23.0,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.notifications_none,
                                                  size: 24,
                                                ),
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Gallery Carousel
                SizedBox(
                  height: 235.0,
                  child: StreamBuilder<List<GalleryItem>>(
                    stream: homeProvider.galleryItemsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final items = snapshot.data!;

                      return Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: CachedNetworkImage(
                                      imageUrl: item.image,
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: items.length,
                            effect: const ExpandingDotsEffect(
                              expansionFactor: 4.0,
                              spacing: 8.0,
                              radius: 8.0,
                              dotWidth: 8.0,
                              dotHeight: 8.0,
                              dotColor: AppTheme.disabled,
                              activeDotColor: AppTheme.amarelo,
                            ),
                            onDotClicked: (index) {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Categories List
                StreamBuilder<List<Category>>(
                  stream: homeProvider.categoriesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma categoria encontrada.'),
                      );
                    }

                    final categories = snapshot.data!;

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _CategorySection(category: category);
                      },
                    );
                  },
                ),

                // Bottom padding for navbar
                const SizedBox(height: 80),
              ],
            ),
          ),
          // Navbar na parte inferior (igual FlutterFlow)
          Align(
            alignment: Alignment.bottomCenter,
            child: NavbarWidget(
              pageIndex: 1,
              onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final Category category;

  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                    color: AppTheme.primaryText,
                  ),
                ),
                InkWell(
                  onTap: () {
                    // Navigate to category details (igual FlutterFlow - ItemCategory)
                    context.push('/category/${category.id}');
                  },
                  child: Row(
                    children: [
                      Text(
                        'ver todos',
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                              fontSize: 12.0,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_ios_sharp, size: 14.0),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items Horizontal List
          SizedBox(
            height: 180.0,
            child: StreamBuilder<List<MenuItem>>(
              stream: homeProvider.getMenuItemsStream(category.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text('Nenhum item nesta categoria.'),
                  );
                }

                final menuItems = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: menuItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8.0),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return _MenuItemCard(item: item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Convert entity to model for navigation
        final itemModel = MenuItemModel.fromEntity(item);
        context.push('/item-details', extra: itemModel);
      },
      child: SizedBox(
        width: 130.0,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: CachedNetworkImage(
                    imageUrl: item.photo,
                    width: 126.0,
                    height: 128.0,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/error_image.png',
                      width: 126.0,
                      height: 128.0,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 126.0,
                        height: 128.0,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.0,
                  ),
                ),
                Text(
                  'R\$ ${item.price.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.amarelo,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
            // Overlay if not available
            if (!item.isAvailable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Indisponível',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
