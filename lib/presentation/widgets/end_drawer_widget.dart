import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class EndDrawerWidget extends StatelessWidget {
  const EndDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user email for now - replace with actual Auth Provider later
    final String currentUserEmail = 'hoteldunamys25@gmail.com'; 
    // Mock app state - replace with actual Provider later
    final bool pedidoEmAndamento = false;

    return Drawer(
      backgroundColor: Colors.white, // Assuming white background based on reference context
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
                  color: Colors.black, // Primary text color
                  size: 24.0,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close drawer
                },
              ),
              
              // Title "Menu"
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  'Menu',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14.0, // bodyMedium default usually 14
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
                onTap: () => context.go('/'), // Navigate to Home
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/3a9k2_3.png',
                label: 'Perfil',
                onTap: () {
                  // context.push('/profile'); 
                  Navigator.of(context).pop();
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/49svh_2.png',
                label: 'Pedidos',
                onTap: () {
                  if (pedidoEmAndamento) {
                    // context.push('/my-orders');
                  } else {
                    // context.push('/cart');
                  }
                  Navigator.of(context).pop();
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/fijek_4.png',
                label: 'Feedback',
                onTap: () {
                  // context.push('/feedback');
                  Navigator.of(context).pop();
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/2emqy_5.png',
                label: 'Perguntas frequentes',
                onTap: () {
                  // context.push('/faq');
                  Navigator.of(context).pop();
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/dfjsb_6.png',
                label: 'SAC',
                onTap: () {
                  // context.push('/sac');
                  Navigator.of(context).pop();
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/x7hc1_7.png',
                label: 'Mapas e Direções',
                onTap: () {
                  // context.push('/maps');
                  Navigator.of(context).pop();
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/k7eg7_8.png',
                label: 'Galeria de imagens',
                onTap: () {
                  // context.push('/gallery');
                  Navigator.of(context).pop();
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/nswz3_9.png',
                label: 'Reservas pelo site',
                onTap: () {
                  // Show Dialog
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return const Dialog(
                        child: SizedBox(
                          height: 200,
                          child: Center(child: Text("Redirect Page Placeholder")),
                        ),
                      );
                    },
                  );
                },
              ),

              const Divider(thickness: 2.0),

              // Admin Button
              if (currentUserEmail == 'hoteldunamys25@gmail.com' || currentUserEmail == 'rafaelhalder@gmail.com')
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: InkWell(
                    onTap: () {
                      // context.push('/admin');
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 130.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(65.0),
                        border: Border.all(
                          color: Colors.black,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Administrador',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
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
            color: Colors.transparent, // primaryBackground
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.cover,
                  width: 40, // Assuming square or similar aspect ratio from reference usage
                  // Reference didn't specify width/height for image, just fit cover inside ClipRRect. 
                  // But usually icons need size. Let's check reference again.
                  // Reference: ClipRRect -> Image.asset. No size on Image. 
                  // But it's inside a Row with height 40 container. 
                  // So the image will likely be constrained by height 40 if it's square.
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.black, // primaryText
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
