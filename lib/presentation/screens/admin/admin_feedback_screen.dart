import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/feedback_service.dart';
import '../../../data/models/feedback_model.dart';

class AdminFeedbackScreen extends StatelessWidget {
  const AdminFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feedbackService = FeedbackService();
    
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
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
          'Feedback dos Clientes',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<FeedbackModel>>(
          stream: feedbackService.getAllFeedbacks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar feedbacks: ${snapshot.error}'),
              );
            }

            final feedbacks = snapshot.data ?? [];

            if (feedbacks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.feedback_outlined,
                      size: 64,
                      color: AppTheme.secondaryText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum feedback recebido',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Calculate average rating
            double totalRating = 0;
            int ratingCount = 0;
            for (var feedback in feedbacks) {
              if (feedback.ranking > 0) {
                totalRating += feedback.ranking;
                ratingCount++;
              }
            }
            final avgRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

            return Column(
              children: [
                // Stats Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.amarelo,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${feedbacks.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Feedbacks',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                avgRating.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                          Text(
                            'Média',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Feedback List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: feedbacks.length,
                    itemBuilder: (context, index) {
                      final feedback = feedbacks[index];

                      return _FeedbackCard(
                        feedbackId: feedback.id,
                        userId: feedback.userId,
                        ranking: feedback.ranking.toDouble(),
                        obs: feedback.obs,
                        emotion: feedback.emotion,
                        date: feedback.date,
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirmar'),
                              content: const Text('Deseja deletar este feedback?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Deletar'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await feedbackService.deleteFeedback(feedback.id);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final String feedbackId;
  final String userId;
  final double ranking;
  final String obs;
  final String emotion;
  final DateTime? date;
  final VoidCallback onDelete;

  const _FeedbackCard({
    required this.feedbackId,
    required this.userId,
    required this.ranking,
    required this.obs,
    required this.emotion,
    required this.date,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateStr = date != null
        ? dateFormat.format(date!)
        : 'Data não disponível';

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
                Text(
                  'Cliente',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryText,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: AppTheme.error,
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            RatingBarIndicator(
              rating: ranking,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 20,
            ),
            if (emotion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.amarelo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  emotion,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.amarelo,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (obs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                obs,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
