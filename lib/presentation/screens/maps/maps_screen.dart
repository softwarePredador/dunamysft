import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/navbar_widget.dart';

class MapsScreen extends StatelessWidget {
  const MapsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 120.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Text(
                    'Mapas e Direções',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color: AppTheme.primaryText,
                    ),
                  ),
                ),

                // Curitiba
                _buildLocationCard(
                  context: context,
                  title: 'Dunamys Curitiba',
                  address: 'R. Comendador Araújo, 499 - Centro\nCuritiba - PR, 80420-000',
                  imageAsset: 'assets/images/dunamys_curitiba.jpg',
                  mapUrl: 'https://www.google.com/maps/place/Dunamys+Hotel/@-25.4045964,-49.2209493,17z',
                ),

                const SizedBox(height: 20.0),

                // Londrina
                _buildLocationCard(
                  context: context,
                  title: 'Dunamys Londrina',
                  address: 'Av. Higienópolis, 401 - Centro\nLondrina - PR, 86020-080',
                  imageAsset: 'assets/images/dunamys_londrina.jpg',
                  mapUrl: 'https://www.google.com/maps/search/Dunamys+Hotel+Londrina',
                ),
              ],
            ),
          ),

          // Navbar
          Align(
            alignment: Alignment.bottomCenter,
            child: NavbarWidget(
              onMenuTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required BuildContext context,
    required String title,
    required String address,
    required String imageAsset,
    required String mapUrl,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
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
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
            child: Image.asset(
              imageAsset,
              width: double.infinity,
              height: 150.0,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 150.0,
                color: AppTheme.grayPaletteGray20,
                child: const Icon(
                  Icons.location_city,
                  size: 64.0,
                  color: AppTheme.amarelo,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    InkWell(
                      onTap: () => _launchUrl(mapUrl),
                      child: Row(
                        children: [
                          Text(
                            'ver no mapa',
                            style: GoogleFonts.inter(
                              fontSize: 14.0,
                              color: AppTheme.amarelo,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 12.0,
                            color: AppTheme.amarelo,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8.0),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 20.0,
                      color: AppTheme.secondaryText,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        address,
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
