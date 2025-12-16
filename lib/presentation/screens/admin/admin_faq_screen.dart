import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class AdminFAQScreen extends StatelessWidget {
  const AdminFAQScreen({super.key});

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
          'Gerenciar FAQ',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFAQDialog(context),
        backgroundColor: AppTheme.adminAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('faq')
              .orderBy('order')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar FAQ: ${snapshot.error}'),
              );
            }

            final faqs = snapshot.data?.docs ?? [];

            if (faqs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 64,
                      color: AppTheme.secondaryText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma FAQ cadastrada',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showFAQDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Criar FAQ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.adminAccent,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: faqs.length,
              onReorder: (oldIndex, newIndex) {
                _reorderFAQs(faqs, oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final faq = faqs[index];
                final faqData = faq.data() as Map<String, dynamic>;

                return _FAQCard(
                  key: ValueKey(faq.id),
                  faqId: faq.id,
                  question: faqData['question'] ?? '',
                  answer: faqData['answer'] ?? '',
                  onEdit: () => _showFAQDialog(
                    context,
                    faqId: faq.id,
                    currentQuestion: faqData['question'],
                    currentAnswer: faqData['answer'],
                  ),
                  onDelete: () => _deleteFAQ(context, faq.id),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _reorderFAQs(
    List<QueryDocumentSnapshot> faqs,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final batch = FirebaseFirestore.instance.batch();

    for (int i = 0; i < faqs.length; i++) {
      int newOrder;
      if (i == oldIndex) {
        newOrder = newIndex;
      } else if (oldIndex < newIndex) {
        if (i > oldIndex && i <= newIndex) {
          newOrder = i - 1;
        } else {
          newOrder = i;
        }
      } else {
        if (i >= newIndex && i < oldIndex) {
          newOrder = i + 1;
        } else {
          newOrder = i;
        }
      }

      batch.update(faqs[i].reference, {'order': newOrder});
    }

    await batch.commit();
  }

  void _showFAQDialog(
    BuildContext context, {
    String? faqId,
    String? currentQuestion,
    String? currentAnswer,
  }) {
    final questionController = TextEditingController(
      text: currentQuestion ?? '',
    );
    final answerController = TextEditingController(text: currentAnswer ?? '');
    final isEditing = faqId != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar FAQ' : 'Nova FAQ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: InputDecoration(
                  labelText: 'Pergunta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: InputDecoration(
                  labelText: 'Resposta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
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
              final question = questionController.text.trim();
              final answer = answerController.text.trim();

              if (question.isEmpty || answer.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pergunta e resposta são obrigatórios'),
                  ),
                );
                return;
              }

              try {
                if (isEditing) {
                  await FirebaseFirestore.instance
                      .collection('faq')
                      .doc(faqId)
                      .update({
                        'question': question,
                        'answer': answer,
                        'updated_at': FieldValue.serverTimestamp(),
                      });
                } else {
                  // Get max order
                  final snapshot = await FirebaseFirestore.instance
                      .collection('faq')
                      .orderBy('order', descending: true)
                      .limit(1)
                      .get();

                  int newOrder = 0;
                  if (snapshot.docs.isNotEmpty) {
                    newOrder =
                        ((snapshot.docs.first.data()['order'] as num?) ?? 0)
                            .toInt() +
                        1;
                  }

                  await FirebaseFirestore.instance.collection('faq').add({
                    'question': question,
                    'answer': answer,
                    'order': newOrder,
                    'created_at': FieldValue.serverTimestamp(),
                  });
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing ? 'FAQ atualizada!' : 'FAQ criada!',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Erro: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.adminAccent,
            ),
            child: Text(isEditing ? 'Salvar' : 'Criar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFAQ(BuildContext context, String faqId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja excluir esta FAQ?'),
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
      await FirebaseFirestore.instance.collection('faq').doc(faqId).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('FAQ excluída!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }
}

class _FAQCard extends StatelessWidget {
  final String faqId;
  final String question;
  final String answer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FAQCard({
    super.key,
    required this.faqId,
    required this.question,
    required this.answer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.drag_handle),
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryText,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  answer,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
