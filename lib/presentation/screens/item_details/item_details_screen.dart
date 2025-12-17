import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/services/auth_service.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/end_drawer_widget.dart';
import '../../widgets/navbar_widget.dart';

class ItemDetailsScreen extends StatefulWidget {
  final MenuItemModel item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _quantity = 1;
  double _totalAdditional = 0.0;
  final List<String> _selectedAdditionals = [];
  final TextEditingController _observationController = TextEditingController();
  List<Map<String, dynamic>> _availableAdditionals = [];
  bool _loadingAdditionals = true;

  double get _totalPrice {
    return (_quantity * widget.item.price) + _totalAdditional;
  }

  @override
  void initState() {
    super.initState();
    _loadAdditionals();
  }

  Future<void> _loadAdditionals() async {
    try {
      final menuRef = FirebaseFirestore.instance
          .collection('menu')
          .doc(widget.item.id);
      final snapshot = await FirebaseFirestore.instance
          .collection('item_additional')
          .where('item', isEqualTo: menuRef)
          .get();

      final List<Map<String, dynamic>> additionals = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final price = _toDouble(data['price']);
        final name = data['name']?.toString() ?? '';

        // Ignorar adicionais sem nome ou com preço zero/negativo
        if (name.isEmpty || price <= 0) continue;

        additionals.add({
          'id': doc.id,
          'name': name,
          'price': price,
          'namePrice':
              data['name_price']?.toString() ??
              '$name - R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}',
        });
      }

      if (mounted) {
        setState(() {
          _availableAdditionals = additionals;
          _loadingAdditionals = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar adicionais: $e');
      if (mounted) {
        setState(() {
          _loadingAdditionals = false;
        });
      }
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  void _updateAdditionalSelection(String name, double price, bool selected) {
    setState(() {
      if (selected) {
        _selectedAdditionals.add(name);
        _totalAdditional += price;
      } else {
        _selectedAdditionals.remove(name);
        _totalAdditional -= price;
      }
    });
  }

  void _addToCart() {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.tr(context).get('login_to_add_cart'))),
      );
      context.push('/login');
      return;
    }

    final cartProvider = context.read<CartProvider>();
    cartProvider.addToCart(
      userId: user.uid,
      menuItemId: widget.item.id,
      menuItemName: widget.item.name,
      menuItemPhoto: widget.item.photo,
      price: widget.item.price,
      quantity: _quantity,
      additionalPrice: _totalAdditional, // Soma do preço dos adicionais
      observation: _observationController.text,
      additionals: _selectedAdditionals,
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.tr(context).get('added_success'),
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        duration: const Duration(milliseconds: 2050),
        backgroundColor: AppTheme.secondary,
      ),
    );

    // Navegar para carrinho (igual FlutterFlow)
    context.push('/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.primaryBackground,
      endDrawer: const EndDrawerWidget(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.065,
        ),
        child: AppBar(
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
      ),
      body: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 120.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    width: double.infinity,
                    height: 200.0,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryBackground,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: widget.item.photo.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.item.photo,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/error_image.png',
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.asset(
                              'assets/images/error_image.png',
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),

                  const SizedBox(height: 8.0),

                  // Product Name
                  Text(
                    widget.item.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                      color: AppTheme.primaryText,
                    ),
                  ),

                  const SizedBox(height: 8.0),

                  // Product Description
                  Text(
                    widget.item.description,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                      color: AppTheme.primaryText,
                    ),
                  ),

                  const SizedBox(height: 10.0),

                  // Product Price
                  Text(
                    'R\$ ${widget.item.price.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.normal,
                      fontSize: 18.0,
                      color: AppTheme.amarelo,
                    ),
                  ),

                  const SizedBox(height: 25.0),

                  // Additionals Section
                  Text(
                    AppLocalizations.tr(context).get('include_items'),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  if (_loadingAdditionals)
                    const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (_availableAdditionals.isEmpty)
                    Text(
                      AppLocalizations.tr(context).get('no_additionals'),
                      style: GoogleFonts.inter(
                        fontSize: 12.0,
                        color: AppTheme.grayPaletteGray60,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _availableAdditionals.map((additional) {
                        final name = additional['name'] as String? ?? '';
                        final price =
                            (additional['price'] as num?)?.toDouble() ?? 0.0;
                        final namePrice =
                            additional['namePrice'] as String? ??
                            '$name - R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
                        final isSelected = _selectedAdditionals.contains(name);
                        return FilterChip(
                          label: Text(namePrice),
                          selected: isSelected,
                          onSelected: (selected) =>
                              _updateAdditionalSelection(name, price, selected),
                          selectedColor: AppTheme.amarelo,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.primaryText,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.amarelo
                                  : AppTheme.bordaCinza,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 20.0),

                  // Observation Section
                  Text(
                    AppLocalizations.tr(context).get('any_observation'),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: AppTheme.grayPaletteGray20,
                        width: 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: _observationController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.tr(context).get('observation_hint'),
                        hintStyle: GoogleFonts.inter(
                          color: AppTheme.grayPaletteGray60,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 180.0),
                ],
              ),
            ),
          ),

          // Bottom: Quantidade + Botão Adicionar lado a lado (igual FlutterFlow)
          Positioned(
            left: 20.0,
            right: 20.0,
            bottom: 100.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Selector
                Container(
                  width: 120.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBackground,
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: AppTheme.grayPaletteGray20,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove_rounded,
                          color: _quantity > 1
                              ? AppTheme.secondaryText
                              : AppTheme.grayPaletteGray20,
                          size: 22.0,
                        ),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Text(
                        '$_quantity',
                        style: GoogleFonts.poppins(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.amarelo,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_rounded,
                          color: AppTheme.secondaryText,
                          size: 22.0,
                        ),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                // Add to Cart Button
                InkWell(
                  onTap: widget.item.isAvailable ? _addToCart : null,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.52,
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: widget.item.isAvailable
                          ? AppTheme.amarelo
                          : AppTheme.grayPaletteGray60,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          widget.item.isAvailable
                              ? AppLocalizations.tr(context).add
                              : AppLocalizations.tr(context).get('unavailable'),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.item.isAvailable)
                          Text(
                            'R\$ ${_totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navbar na parte inferior (igual FlutterFlow)
          Align(
            alignment: Alignment.bottomCenter,
            child: NavbarWidget(
              pageIndex: 0,
              onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ),
        ],
      ),
    );
  }
}
