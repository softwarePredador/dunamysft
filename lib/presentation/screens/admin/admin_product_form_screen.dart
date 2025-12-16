import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';

class AdminProductFormScreen extends StatefulWidget {
  final String? productId;
  final String? categoryId;

  const AdminProductFormScreen({
    super.key,
    this.productId,
    this.categoryId,
  });

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _photoUrlController = TextEditingController();

  String? _selectedCategoryId;
  bool _isAvailable = true;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  File? _selectedImage;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, TextEditingController>> _additionals = [];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _loadCategories();
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('category').get();
    setState(() {
      _categories = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name'] ?? 'Categoria'})
          .toList();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final fileName = 'products/${DateTime.now().millisecondsSinceEpoch}_${_nameController.text.isNotEmpty ? _nameController.text.replaceAll(' ', '_') : 'produto'}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      final uploadTask = await ref.putFile(
        _selectedImage!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        _photoUrlController.text = downloadUrl;
        _selectedImage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagem enviada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer upload: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecionar Imagem',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Câmera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Galeria',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.amarelo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.amarelo),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppTheme.amarelo),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('menu')
          .doc(widget.productId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _priceController.text = (data['price'] as num?)?.toString() ?? '';
        _stockController.text = (data['stock'] as num?)?.toString() ?? '1';
        _photoUrlController.text = data['photo'] ?? '';
        _isAvailable = data['available'] ?? true;

        final categoryRef = data['categoryRefID'] as DocumentReference?;
        if (categoryRef != null) {
          _selectedCategoryId = categoryRef.id;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar produto: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'stock': int.tryParse(_stockController.text) ?? 1,
        'photo': _photoUrlController.text.trim(),
        'available': _isAvailable,
        'categoryRefID': FirebaseFirestore.instance
            .collection('category')
            .doc(_selectedCategoryId),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (widget.productId != null) {
        // Update
        await FirebaseFirestore.instance
            .collection('menu')
            .doc(widget.productId)
            .update(data);
      } else {
        // Create
        data['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('menu').add(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.productId != null
                ? 'Produto atualizado!'
                : 'Produto criado!'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteProduct() async {
    if (widget.productId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este produto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('menu')
          .doc(widget.productId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluído!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _photoUrlController.dispose();
    for (var additional in _additionals) {
      additional['name']?.dispose();
      additional['price']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_sharp,
            color: AppTheme.amarelo,
            size: 35,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin/products');
            }
          },
        ),
        title: Text(
          isEditing ? 'Editar Produto' : 'Novo Produto',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteProduct,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview da Imagem com botão de upload
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _isUploadingImage ? null : _showImageSourceDialog,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.amarelo.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: _isUploadingImage
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const CircularProgressIndicator(
                                              color: AppTheme.amarelo,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Enviando...',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: AppTheme.secondaryText,
                                              ),
                                            ),
                                          ],
                                        )
                                      : _selectedImage != null
                                          ? Image.file(
                                              _selectedImage!,
                                              fit: BoxFit.cover,
                                              width: 150,
                                              height: 150,
                                            )
                                          : _photoUrlController.text.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: _photoUrlController.text,
                                                  fit: BoxFit.cover,
                                                  width: 150,
                                                  height: 150,
                                                  placeholder: (context, url) => const Center(
                                                    child: CircularProgressIndicator(),
                                                  ),
                                                  errorWidget: (context, url, error) => Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.broken_image, 
                                                        size: 40, 
                                                        color: AppTheme.secondaryText),
                                                      const SizedBox(height: 8),
                                                      Text('URL inválida',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          color: AppTheme.secondaryText,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.add_a_photo,
                                                      size: 40,
                                                      color: AppTheme.amarelo),
                                                    const SizedBox(height: 8),
                                                    Text('Toque para\nadicionar',
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        color: AppTheme.secondaryText,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                ),
                              ),
                            ),
                            // Botão de editar imagem (quando já tem imagem)
                            if (_photoUrlController.text.isNotEmpty && !_isUploadingImage)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: _showImageSourceDialog,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.amarelo,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Texto indicativo
                      Center(
                        child: Text(
                          'Toque na imagem para fazer upload',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Photo URL (oculto por padrão, expansível)
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Icon(Icons.link, size: 18, color: AppTheme.secondaryText),
                            const SizedBox(width: 8),
                            Text(
                              'Ou cole uma URL de imagem',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          TextFormField(
                            controller: _photoUrlController,
                            decoration: _inputDecoration('Cole a URL da imagem'),
                            onChanged: (value) => setState(() {}),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Card de Informações Básicas
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informações do Produto',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Name
                            _buildLabel('Nome do Produto *', Icons.restaurant_menu),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              decoration: _inputDecoration('Ex: Hambúrguer Artesanal'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nome é obrigatório';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Description
                            _buildLabel('Descrição', Icons.description),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: _inputDecoration('Descrição do produto'),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),

                            // Category
                            _buildLabel('Categoria *', Icons.category),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.primaryText.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCategoryId,
                                  hint: Text('Selecione uma categoria',
                                    style: GoogleFonts.inter(color: AppTheme.secondaryText),
                                  ),
                                  isExpanded: true,
                                  items: _categories.map((cat) {
                                    return DropdownMenuItem<String>(
                                      value: cat['id'],
                                      child: Text(cat['name']),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategoryId = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Card de Preço e Estoque
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preço e Disponibilidade',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Price and Stock Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Preço *', Icons.attach_money),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _priceController,
                                        decoration: _inputDecoration('0.00').copyWith(
                                          prefixText: 'R\$ ',
                                          prefixStyle: GoogleFonts.inter(
                                            color: AppTheme.primaryText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Obrigatório';
                                          }
                                          if (double.tryParse(value) == null) {
                                            return 'Inválido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Estoque', Icons.inventory),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _stockController,
                                        decoration: _inputDecoration('1'),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Available Switch
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isAvailable 
                                    ? AppTheme.amarelo.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isAvailable ? AppTheme.amarelo : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _isAvailable ? Icons.check_circle : Icons.cancel,
                                        color: _isAvailable ? AppTheme.amarelo : Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isAvailable ? 'Produto Disponível' : 'Produto Indisponível',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: _isAvailable ? AppTheme.amarelo : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: _isAvailable,
                                    activeColor: AppTheme.amarelo,
                                    onChanged: (value) {
                                      setState(() {
                                        _isAvailable = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveProduct,
                          icon: _isSaving 
                              ? const SizedBox.shrink()
                              : Icon(isEditing ? Icons.save : Icons.add_circle, color: Colors.white),
                          label: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  isEditing ? 'Salvar Alterações' : 'Cadastrar Produto',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.amarelo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.amarelo),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryText,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppTheme.secondaryText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primaryText),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primaryText),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.amarelo, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
