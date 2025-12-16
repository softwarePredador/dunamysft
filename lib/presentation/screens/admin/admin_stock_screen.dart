import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class AdminStockScreen extends StatelessWidget {
  const AdminStockScreen({super.key});

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
          'Estoque de Produtos',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('menu')
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar produtos: ${snapshot.error}'),
              );
            }

            final products = snapshot.data?.docs ?? [];

            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: AppTheme.secondaryText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum produto cadastrado',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final productData = product.data() as Map<String, dynamic>;
                final name = productData['name'] ?? 'Produto';
                final stock = (productData['stock'] as num?)?.toInt() ?? 0;
                final isAvailable = productData['available'] ?? true;

                return _StockCard(
                  productId: product.id,
                  name: name,
                  stock: stock,
                  isAvailable: isAvailable,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StockCard extends StatefulWidget {
  final String productId;
  final String name;
  final int stock;
  final bool isAvailable;

  const _StockCard({
    required this.productId,
    required this.name,
    required this.stock,
    required this.isAvailable,
  });

  @override
  State<_StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<_StockCard> {
  late int _currentStock;
  late bool _isAvailable;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStock = widget.stock;
    _isAvailable = widget.isAvailable;
  }

  Future<void> _updateStock(int newStock) async {
    if (newStock < 0) return;

    setState(() {
      _isUpdating = true;
      _currentStock = newStock;
    });

    try {
      await FirebaseFirestore.instance
          .collection('menu')
          .doc(widget.productId)
          .update({'stock': newStock});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar estoque: $e')),
        );
        setState(() {
          _currentStock = widget.stock;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _toggleAvailability() async {
    final newValue = !_isAvailable;

    setState(() {
      _isUpdating = true;
      _isAvailable = newValue;
    });

    try {
      await FirebaseFirestore.instance
          .collection('menu')
          .doc(widget.productId)
          .update({'available': newValue});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar disponibilidade: $e')),
        );
        setState(() {
          _isAvailable = !newValue;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockColor = _currentStock == 0
        ? Colors.red
        : _currentStock < 5
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryText,
                    ),
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  activeColor: AppTheme.amarelo,
                  onChanged: _isUpdating ? null : (value) => _toggleAvailability(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Estoque: ',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: stockColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_currentStock',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: stockColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStock(_currentStock - 1),
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryText,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStock(_currentStock + 1),
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.amarelo,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
