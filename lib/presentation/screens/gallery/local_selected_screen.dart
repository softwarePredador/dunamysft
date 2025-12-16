import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/local_dunamys_model.dart';
import '../../../data/models/gallery_local_model.dart';
import '../../../data/services/gallery_service.dart';
import '../../widgets/navbar_widget.dart';
import '../../widgets/end_drawer_widget.dart';

class LocalSelectedScreen extends StatefulWidget {
  final LocalDunamysModel local;

  const LocalSelectedScreen({
    super.key,
    required this.local,
  });

  @override
  State<LocalSelectedScreen> createState() => _LocalSelectedScreenState();
}

class _LocalSelectedScreenState extends State<LocalSelectedScreen> {
  final GalleryService _galleryService = GalleryService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.primaryBackground,
      endDrawer: const EndDrawerWidget(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // AppBar customizado
                Container(
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_circle_left_sharp,
                          color: AppTheme.amarelo,
                          size: 35.0,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/gallery');
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          widget.local.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                            color: AppTheme.primaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48.0), // Balance for back button
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: StreamBuilder<List<GalleryLocalModel>>(
                    stream: _galleryService.getGalleryByLocal(widget.local.reference),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.photo_library_outlined,
                                size: 64.0,
                                color: AppTheme.grayPaletteGray60,
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                'Nenhuma mídia disponível',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.0,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final items = snapshot.data!;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _GalleryItemCard(
                            item: item,
                            onTap: () => _openMedia(context, item),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
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

  void _openMedia(BuildContext context, GalleryLocalModel item) {
    if (item.hasVideo) {
      _showVideoPlayer(context, item.video);
    } else if (item.hasImage) {
      _showFullImage(context, item.image);
    }
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

  void _showVideoPlayer(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (context) => _VideoPlayerDialog(videoUrl: videoUrl),
    );
  }
}

class _GalleryItemCard extends StatelessWidget {
  final GalleryLocalModel item;
  final VoidCallback onTap;

  const _GalleryItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8.0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagem de fundo
              Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.grayPaletteGray20,
                    child: const Icon(
                      Icons.image,
                      size: 48.0,
                      color: AppTheme.grayPaletteGray60,
                    ),
                  );
                },
              ),
              // Overlay para vídeo
              if (item.hasVideo)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 48.0,
                      color: Colors.white,
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

class _VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerDialog({required this.videoUrl});

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      await _controller.play();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(10.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_hasError)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar vídeo',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            )
          else if (!_isInitialized)
            const CircularProgressIndicator(color: Colors.white)
          else
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
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
    );
  }
}
