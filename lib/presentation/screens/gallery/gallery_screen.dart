import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/local_dunamys_model.dart';
import '../../../data/models/gallery_local_model.dart';
import '../../../data/services/gallery_service.dart';
import '../../widgets/navbar_widget.dart';
import '../../widgets/end_drawer_widget.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final GalleryService _galleryService = GalleryService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.primaryBackground,
      endDrawer: const EndDrawerWidget(),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 120.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    AppLocalizations.tr(context).get('photo_video_gallery'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  
                  const SizedBox(height: 20.0),

                  // Carrossel de imagens
                  _buildGalleryCarousel(),

                  const SizedBox(height: 30.0),

                  // Seção "Explore por local"
                  Text(
                    AppLocalizations.tr(context).get('explore_by_location'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color: AppTheme.primaryText,
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Lista de locais
                  _buildLocalsList(),
                ],
              ),
            ),
          ),

          // Navbar
          Align(
            alignment: Alignment.bottomCenter,
            child: NavbarWidget(
              onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryCarousel() {
    return StreamBuilder<List<GalleryLocalModel>>(
      stream: _galleryService.getAllGalleryItems(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 235.0,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data!;
        if (items.isEmpty) {
          return Container(
            height: 235.0,
            decoration: BoxDecoration(
              color: AppTheme.grayPaletteGray20,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Center(
              child: Text(AppLocalizations.tr(context).get('no_images_available')),
            ),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 200.0,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () => _showFullImage(context, item.image),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          item.image,
                          width: 350.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.grayPaletteGray20,
                              child: const Icon(
                                Icons.image,
                                size: 64,
                                color: AppTheme.grayPaletteGray60,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            // Indicadores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                items.length > 10 ? 10 : items.length,
                (index) => Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppTheme.amarelo
                        : AppTheme.grayPaletteGray30,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocalsList() {
    return StreamBuilder<List<LocalDunamysModel>>(
      stream: _galleryService.getLocals(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final locals = snapshot.data!;
        if (locals.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: const Center(
              child: Text('Nenhum local cadastrado'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: locals.length,
          itemBuilder: (context, index) {
            final local = locals[index];
            return _LocalCard(
              local: local,
              galleryService: _galleryService,
              onTap: () => context.push('/gallery/local', extra: local),
            );
          },
        );
      },
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalCard extends StatelessWidget {
  final LocalDunamysModel local;
  final GalleryService galleryService;
  final VoidCallback onTap;

  const _LocalCard({
    required this.local,
    required this.galleryService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem de capa do local
              StreamBuilder<List<GalleryLocalModel>>(
                stream: galleryService.getGalleryByLocal(local.reference),
                builder: (context, snapshot) {
                  String? imageUrl;
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    imageUrl = snapshot.data!.first.image;
                  }
                  
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16.0),
                    ),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            height: 150.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                        : _buildPlaceholder(),
                  );
                },
              ),
              // Nome do local
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      local.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                      color: AppTheme.secondaryText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150.0,
      width: double.infinity,
      color: AppTheme.grayPaletteGray20,
      child: const Icon(
        Icons.photo_library,
        size: 48.0,
        color: AppTheme.grayPaletteGray60,
      ),
    );
  }
}
