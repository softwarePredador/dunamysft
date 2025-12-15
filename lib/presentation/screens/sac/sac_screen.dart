import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/navbar_widget.dart';

class SACScreen extends StatelessWidget {
  const SACScreen({super.key});

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/${phone.replaceAll(RegExp(r'[^\d]'), '')}');
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
          onPressed: () => context.pop(),
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
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'SAC',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color: AppTheme.primaryText,
                    ),
                  ),
                ),

                const SizedBox(height: 50.0),

                // Telefones
                Text(
                  'Telefones',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: AppTheme.secondaryText,
                  ),
                ),

                const SizedBox(height: 8.0),

                // Curitiba
                _buildPhoneRow(
                  phone: '+55 41 3251-3300',
                  location: '(Curitiba)',
                  onTap: () => _launchPhone('+554132513300'),
                ),

                // Londrina
                _buildPhoneRow(
                  phone: '+55 43 3374-3737',
                  location: '(Londrina)',
                  onTap: () => _launchPhone('+554333743737'),
                ),

                const SizedBox(height: 30.0),

                // Redes Sociais
                Text(
                  'Nossas redes sociais',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: AppTheme.secondaryText,
                  ),
                ),

                const SizedBox(height: 12.0),

                // Instagram
                _buildSocialRow(
                  icon: FontAwesomeIcons.instagram,
                  label: 'Instagram',
                  onTap: () => _launchUrl('https://www.instagram.com/hoteldunamys/'),
                ),

                // Facebook
                _buildSocialRow(
                  icon: FontAwesomeIcons.facebook,
                  label: 'Facebook',
                  onTap: () => _launchUrl('https://www.facebook.com/hoteldunamys'),
                ),

                const SizedBox(height: 30.0),

                // Email
                Text(
                  'E-mail',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: AppTheme.secondaryText,
                  ),
                ),

                const SizedBox(height: 8.0),

                _buildEmailRow(
                  email: 'contato@hoteldunamys.com.br',
                  onTap: () => _launchEmail('contato@hoteldunamys.com.br'),
                ),

                const SizedBox(height: 30.0),

                // WhatsApp
                Text(
                  'WhatsApp',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: AppTheme.secondaryText,
                  ),
                ),

                const SizedBox(height: 12.0),

                // WhatsApp Curitiba
                _buildWhatsAppRow(
                  phone: '+55 41 99999-9999',
                  location: 'Curitiba',
                  onTap: () => _launchWhatsApp('+5541999999999'),
                ),

                // WhatsApp Londrina
                _buildWhatsAppRow(
                  phone: '+55 43 99999-9999',
                  location: 'Londrina',
                  onTap: () => _launchWhatsApp('+5543999999999'),
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

  Widget _buildPhoneRow({
    required String phone,
    required String location,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Text(
              '$phone ',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
                color: AppTheme.primaryText,
              ),
            ),
            Text(
              location,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            FaIcon(
              icon,
              color: AppTheme.amarelo,
              size: 24.0,
            ),
            const SizedBox(width: 10.0),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailRow({
    required String email,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            const Icon(
              Icons.email_outlined,
              color: AppTheme.amarelo,
              size: 24.0,
            ),
            const SizedBox(width: 10.0),
            Text(
              email,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppRow({
    required String phone,
    required String location,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Color(0xFF25D366),
              size: 24.0,
            ),
            const SizedBox(width: 10.0),
            Text(
              '$phone ',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                color: AppTheme.primaryText,
              ),
            ),
            Text(
              '($location)',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
