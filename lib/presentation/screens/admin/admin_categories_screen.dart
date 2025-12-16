import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

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
          'Categorias',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        backgroundColor: AppTheme.amarelo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('category')
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar categorias: ${snapshot.error}'),
              );
            }

            final categories = snapshot.data?.docs ?? [];

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
                    ElevatedButton.icon(
                      onPressed: () => _showCategoryDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Criar Categoria'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.amarelo,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryData = category.data() as Map<String, dynamic>;
                final name = categoryData['name'] ?? 'Categoria';
                final photoUrl = categoryData['photo'] ?? '';

                return _CategoryCard(
                  categoryId: category.id,
                  name: name,
                  photoUrl: photoUrl,
                  onEdit: () => _showCategoryDialog(
                    context,
                    categoryId: category.id,
                    currentName: name,
                    currentPhotoUrl: photoUrl,
                  ),
                  onDelete: () => _deleteCategory(context, category.id, name),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context, {
    String? categoryId,
    String? currentName,
    String? currentPhotoUrl,
  }) {
    final nameController = TextEditingController(text: currentName ?? '');
    final photoController = TextEditingController(text: currentPhotoUrl ?? '');
    final isEditing = categoryId != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Categoria' : 'Nova Categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome da Categoria',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: photoController,
              decoration: InputDecoration(
                labelText: 'URL da Foto (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome é obrigatório')),
                );
                return;
              }

              final data = {
                'name': name,
                'photo': photoController.text.trim(),
                'updated_at': FieldValue.serverTimestamp(),
              };

              try {
                if (isEditing) {
                  await FirebaseFirestore.instance
                      .collection('category')
                      .doc(categoryId)
                      .update(data);
                } else {
                  data['created_at'] = FieldValue.serverTimestamp();
                  await FirebaseFirestore.instance.collection('category').add(data);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing ? 'Categoria atualizada!' : 'Categoria criada!',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.amarelo,
            ),
            child: Text(isEditing ? 'Salvar' : 'Criar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    String categoryId,
    String name,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir a categoria "$name"?'),
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
          .collection('category')
          .doc(categoryId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoria excluída!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final String categoryId;
  final String name;
  final String photoUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.categoryId,
    required this.name,
    required this.photoUrl,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.amarelo.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: photoUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.category,
                      color: AppTheme.amarelo,
                    ),
                  ),
                )
              : Icon(
                  Icons.category,
                  color: AppTheme.amarelo,
                  size: 30,
                ),
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryText,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppTheme.primaryText),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
