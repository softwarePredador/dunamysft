import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class AdminMediaScreen extends StatelessWidget {
  const AdminMediaScreen({super.key});

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
            color: AppTheme.adminAccent,
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
          'Cadastro de Imagens',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLocalDialog(context),
        backgroundColor: AppTheme.adminAccent,
        child: const Icon(Icons.add_location_alt, color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('localDunamys')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar locais: ${snapshot.error}'),
              );
            }

            final locals = snapshot.data?.docs ?? [];

            if (locals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: AppTheme.secondaryText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum local cadastrado',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddLocalDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Local'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.adminAccent,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: locals.length,
              itemBuilder: (context, index) {
                final local = locals[index];
                final localData = local.data() as Map<String, dynamic>;
                final localName = localData['name'] ?? 'Local';

                return _LocalMediaSection(
                  localId: local.id,
                  localName: localName,
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddLocalDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Local'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nome do Local',
            hintText: 'Ex: Piscina, Restaurante...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome é obrigatório')),
                );
                return;
              }

              await FirebaseFirestore.instance.collection('localDunamys').add({
                'name': name,
                'created_at': FieldValue.serverTimestamp(),
              });

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Local criado!')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.adminAccent,
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}

class _LocalMediaSection extends StatelessWidget {
  final String localId;
  final String localName;

  const _LocalMediaSection({required this.localId, required this.localName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localName,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editLocal(context),
                  tooltip: 'Editar Local',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _deleteLocal(context),
                  tooltip: 'Excluir Local',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('gallerylocal')
                .where(
                  'local',
                  isEqualTo: FirebaseFirestore.instance
                      .collection('localDunamys')
                      .doc(localId),
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data?.docs ?? [];

              return Row(
                children: [
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhuma mídia',
                              style: GoogleFonts.inter(
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final itemData =
                                  item.data() as Map<String, dynamic>;
                              final imageUrl = itemData['image'] ?? '';
                              final videoUrl = itemData['video'] ?? '';

                              return _MediaItem(
                                itemId: item.id,
                                imageUrl: imageUrl,
                                hasVideo: videoUrl.isNotEmpty,
                              );
                            },
                          ),
                  ),
                  const SizedBox(width: 10),
                  // Add Media Button
                  InkWell(
                    onTap: () => _showAddMediaDialog(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.secondaryText),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate,
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
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 10),
      ],
    );
  }

  void _editLocal(BuildContext context) {
    final controller = TextEditingController(text: localName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Local'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nome do Local',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('localDunamys')
                  .doc(localId)
                  .update({'name': name});

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.adminAccent,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _deleteLocal(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Local'),
        content: Text('Deseja excluir "$localName" e todas as suas mídias?'),
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
      // Deletar todas as mídias do local
      final mediaSnapshot = await FirebaseFirestore.instance
          .collection('gallerylocal')
          .where(
            'local',
            isEqualTo: FirebaseFirestore.instance
                .collection('localDunamys')
                .doc(localId),
          )
          .get();

      for (final doc in mediaSnapshot.docs) {
        await doc.reference.delete();
      }

      // Deletar o local
      await FirebaseFirestore.instance
          .collection('localDunamys')
          .doc(localId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Local excluído!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }

  void _showAddMediaDialog(BuildContext context) {
    final imageController = TextEditingController();
    final videoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar Mídia - $localName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: imageController,
                decoration: InputDecoration(
                  labelText: 'URL da Imagem *',
                  hintText: 'Cole a URL da imagem',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: videoController,
                decoration: InputDecoration(
                  labelText: 'URL do Vídeo (opcional)',
                  hintText: 'Cole a URL do vídeo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nota: Para upload de arquivos, use o Firebase Storage e cole a URL aqui.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final imageUrl = imageController.text.trim();
              if (imageUrl.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL da imagem é obrigatória')),
                );
                return;
              }

              await FirebaseFirestore.instance.collection('gallerylocal').add({
                'image': imageUrl,
                'video': videoController.text.trim(),
                'local': FirebaseFirestore.instance
                    .collection('localDunamys')
                    .doc(localId),
                'created_at': FieldValue.serverTimestamp(),
              });

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mídia adicionada!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.adminAccent,
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

class _MediaItem extends StatelessWidget {
  final String itemId;
  final String imageUrl;
  final bool hasVideo;

  const _MediaItem({
    required this.itemId,
    required this.imageUrl,
    required this.hasVideo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDeleteDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 100,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 120,
                      color: AppTheme.secondaryText.withValues(alpha: 0.2),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 120,
                      color: AppTheme.secondaryText.withValues(alpha: 0.2),
                      child: const Icon(Icons.broken_image),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 120,
                    color: AppTheme.secondaryText.withValues(alpha: 0.2),
                    child: const Icon(Icons.image),
                  ),
          ),
          if (hasVideo)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Mídia'),
        content: const Text('Deseja excluir esta mídia?'),
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

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('gallerylocal')
          .doc(itemId)
          .delete();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mídia excluída!')));
      }
    }
  }
}
