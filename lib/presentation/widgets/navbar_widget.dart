import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class NavbarWidget extends StatelessWidget {
  final int pageIndex;

  const NavbarWidget({
    super.key,
    this.pageIndex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115.0,
      child: Stack(
        children: [
          // Background SVG
          Align(
            alignment: const AlignmentDirectional(0.0, 1.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: SvgPicture.asset(
                'assets/images/navbar_4_bg_white.svg',
                width: double.infinity,
                height: 75.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Navigation Items
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
            child: Container(
              width: double.infinity,
              height: 72.0,
              constraints: const BoxConstraints(
                minHeight: 76.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 14.0),
                  
                  // Menu Item
                  Expanded(
                    flex: 2,
                    child: _NavbarItem(
                      imagePath: 'assets/images/login1_(2).png',
                      onTap: () => context.push('/menu'),
                    ),
                  ),
                  
                  const SizedBox(width: 8.0),

                  // Cart Item
                  Expanded(
                    flex: 2,
                    child: _NavbarItem(
                      imagePath: 'assets/images/Group_132.png',
                      onTap: () => context.push('/cart'),
                    ),
                  ),
                  
                  const Spacer(flex: 3), // Space for the center button
                  
                  const SizedBox(width: 8.0),

                  // Profile Item
                  Expanded(
                    flex: 2,
                    child: _NavbarItem(
                      imagePath: 'assets/images/Group_133.png',
                      onTap: () => context.push('/profile'),
                    ),
                  ),
                  
                  const SizedBox(width: 8.0),

                  // More/Redirect Item
                  Expanded(
                    flex: 2,
                    child: _NavbarItem(
                      imagePath: 'assets/images/Group_134.png',
                      onTap: () {
                        // Show redirect dialog or navigate
                        // For now, just print
                        print('More tapped');
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 14.0),
                ],
              ),
            ),
          ),
          
          // Center Floating Button (Home)
          Align(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: InkWell(
              onTap: () => context.go('/home'),
              child: Container(
                width: 64.0,
                height: 64.0,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD0AA5E), Color(0xFFCD9A32)],
                    stops: [0.5, 1.0],
                    begin: AlignmentDirectional(0.0, -1.0),
                    end: AlignmentDirectional(0, 1.0),
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/95z4v_s.png',
                    width: 80.0,
                    height: 60.0,
                    fit: BoxFit.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavbarItem extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _NavbarItem({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              imagePath,
              width: 80.0,
              height: 60.0,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
