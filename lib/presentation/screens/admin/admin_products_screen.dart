import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_circle_left_sharp,
            color: AppTheme.primaryText,
            size: 35,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin');
            }
          },
        ),
        title: Text(
          'Cadastro de Produtos',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/products/new'),
        backgroundColor: AppTheme.amarelo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('category').snapshots(),
          builder: (context, categorySnapshot) {
            if (categorySnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (categorySnapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar categorias: ${categorySnapshot.error}'),
              );
            }

            final categories = categorySnapshot.data?.docs ?? [];

            if (categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: AppTheme.secondaryText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma categoria cadastrada',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/admin/categories'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.amarelo,
                      ),
                      child: const Text('Criar Categoria'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryData = category.data() as Map<String, dynamic>;
                final categoryName = categoryData['name'] ?? 'Categoria';

                return _CategorySection(
                  categoryId: category.id,
                  categoryName: categoryName,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const _CategorySection({
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            categoryName,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryText,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('menu')
                .where('categoryRefID',
                    isEqualTo:
                        FirebaseFirestore.instance.collection('category').doc(categoryId))
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = snapshot.data?.docs ?? [];

              return Row(
                children: [
                  Expanded(
                    child: products.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhum produto nesta categoria',
                              style: GoogleFonts.inter(
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final productData =
                                  product.data() as Map<String, dynamic>;

                              return _ProductCard(
                                productId: product.id,
                                name: productData['name'] ?? 'Produto',
                                price:
                                    (productData['price'] as num?)?.toDouble() ??
                                        0.0,
                                imageUrl: productData['photo'] ?? '',
                                isAvailable: productData['available'] ?? true,
                              );
                            },
                          ),
                  ),
                  // Add Product Button
                  InkWell(
                    onTap: () => context.push('/admin/products/new?category=$categoryId'),
                    child: Container(
                      width: 100,
                      height: 180,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.secondaryText,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 32,
                            color: AppTheme.secondaryText,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Adicionar',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final bool isAvailable;

  const _ProductCard({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/admin/products/$productId'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryText.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 140,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.secondaryText.withOpacity(0.2),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 140,
                            height: 100,
                            color: AppTheme.secondaryText.withOpacity(0.2),
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : Container(
                          width: 140,
                          height: 100,
                          color: AppTheme.secondaryText.withOpacity(0.2),
                          child: const Icon(Icons.fastfood),
                        ),
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: Text(
                            'INDISPONÍVEL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${price.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.amarelo,
                    ),
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
