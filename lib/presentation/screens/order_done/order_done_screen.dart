import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../widgets/navbar_widget.dart';

class OrderDoneScreen extends StatefulWidget {
  final String orderId;

  const OrderDoneScreen({super.key, required this.orderId});

  @override
  State<OrderDoneScreen> createState() => _OrderDoneScreenState();
}

class _OrderDoneScreenState extends State<OrderDoneScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/video1.mp4');
    try {
      await _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.setVolume(0); // Mute
      _videoController.play();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: Stack(
        children: [
          // Main Content
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 50.0, 20.0, 0.0),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: FutureBuilder(
                future: context.read<OrderProvider>().getOrderById(widget.orderId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryText)));
                  }

                  final order = snapshot.data;

                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Title
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Pedido confirmado!',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 20.0, color: AppTheme.primaryText),
                        ),
                      ),

                      // Order Code
                      Align(
                        alignment: Alignment.center,
                        child: Text('Código ${order?.codigo ?? ''}', style: GoogleFonts.inter(fontSize: 14.0, color: AppTheme.primaryText)),
                      ),

                      // Video Animation
                      Container(
                        width: 270.0,
                        height: 201.0,
                        decoration: const BoxDecoration(),
                        child: _isVideoInitialized
                            ? AspectRatio(aspectRatio: _videoController.value.aspectRatio, child: VideoPlayer(_videoController))
                            : const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.amarelo))),
                      ),

                      // Total Label
                      Align(
                        alignment: Alignment.center,
                        child: Text('Total', style: GoogleFonts.inter(fontSize: 14.0, color: AppTheme.primaryText)),
                      ),

                      // Total Value
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                          child: Text(
                            'R\$ ${(order?.total ?? 0).toStringAsFixed(2).replaceAll('.', ',')}',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 40.0, color: AppTheme.amarelo),
                          ),
                        ),
                      ),

                      // Confirmation Message
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
                          child: Text(
                            'Seu pagamento foi confirmado e seu pedido está sendo preparado.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 16.0, color: AppTheme.primaryText),
                          ),
                        ),
                      ),

                      // Estimated Time
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Tempo estimado: ', style: GoogleFonts.inter(fontSize: 16.0, color: AppTheme.primaryText)),
                              Text('25 min', style: GoogleFonts.inter(fontSize: 16.0, color: AppTheme.amarelo)),
                            ],
                          ),
                        ),
                      ),

                      // View Orders Button
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () => context.push('/orders'),
                            child: Container(
                              width: double.infinity,
                              height: 80.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(color: AppTheme.amarelo, width: 1.0),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Ver meus pedidos',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16.0, color: AppTheme.primaryText),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Receive Receipt by Email (optional link)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                        child: InkWell(
                          onTap: () {
                            // TODO: Implement send receipt by email
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(const SnackBar(content: Text('Nota fiscal enviada para seu e-mail!'), backgroundColor: AppTheme.success));
                          },
                          child: Text(
                            'Receber nota fiscal por e-mail?',
                            style: GoogleFonts.inter(fontSize: 14.0, color: AppTheme.secondaryText, decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Navbar
          const Align(alignment: Alignment.bottomCenter, child: NavbarWidget()),
        ],
      ),
    );
  }
}
