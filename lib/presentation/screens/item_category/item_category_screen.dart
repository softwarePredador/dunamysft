import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/menu_item_model.dart';
import '../../widgets/end_drawer_widget.dart';
import '../../widgets/navbar_widget.dart';

class ItemCategoryScreen extends StatefulWidget {
  final String categoryId;

  const ItemCategoryScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<ItemCategoryScreen> createState() => _ItemCategoryScreenState();
}

class _ItemCategoryScreenState extends State<ItemCategoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final categoryRef = FirebaseFirestore.instance
        .collection('category')
        .doc(widget.categoryId);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.primaryBackground,
      endDrawer: const EndDrawerWidget(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.065),
        child: AppBar(
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
          actions: const [],
        ),
      ),
      body: SafeArea(
        top: true,
        child: SizedBox(
          height: double.infinity,
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('menu')
                              .where('categoryRefID', isEqualTo: categoryRef)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: SizedBox(
                                  width: 50.0,
                                  height: 50.0,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryText,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final menuItems = snapshot.data!.docs
                                .map((doc) => MenuItemModel.fromFirestore(doc))
                                .where((item) => !item.excluded)
                                .toList();

                            if (menuItems.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Text(
                                    'Nenhum item nesta categoria',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.0,
                                      color: AppTheme.secondaryText,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: menuItems.length,
                              itemBuilder: (context, index) {
                                final item = menuItems[index];
                                return _buildMenuItem(context, item);
                              },
                            );
                          },
                        ),
                        // Space for navbar
                        const SizedBox(height: 120),
                      ],
                    ),
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
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItemModel item) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        context.push('/item-details', extra: item);
      },
      child: Container(
        width: double.infinity,
        height: 250.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Image Container
            Container(
              width: double.infinity,
              height: 200.0,
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackground,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                child: Hero(
                  tag: item.photo.isNotEmpty ? item.photo : 'item_${item.id}',
                  transitionOnUserGestures: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: item.photo.isNotEmpty
                        ? CachedNetworkImage(
                            fadeInDuration: const Duration(milliseconds: 500),
                            fadeOutDuration: const Duration(milliseconds: 500),
                            imageUrl: item.photo,
                            width: double.infinity,
                            height: 200.0,
                            fit: BoxFit.contain,
                            errorWidget: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/images/error_image.png',
                              width: double.infinity,
                              height: 200.0,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            'assets/images/error_image.png',
                            width: double.infinity,
                            height: 200.0,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
            ),
            // Name and Price Row
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 5.0),
              child: SizedBox(
                width: double.infinity,
                height: 27.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0,
                          color: AppTheme.primaryText,
                        ),
                      ),
                    ),
                    Text(
                      'R\$ ${item.price.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 18.0,
                        color: AppTheme.amarelo,
                      ),
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
