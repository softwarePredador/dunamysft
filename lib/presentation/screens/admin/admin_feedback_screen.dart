import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class AdminFeedbackScreen extends StatelessWidget {
  const AdminFeedbackScreen({super.key});

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
          onPressed: () => context.pop(),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('feedback')
              .orderBy('created_at', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar feedbacks: ${snapshot.error}'),
              );
            }

            final feedbacks = snapshot.data?.docs ?? [];

            if (feedbacks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
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
            for (var doc in feedbacks) {
              final data = doc.data() as Map<String, dynamic>;
              final rating = (data['rating'] as num?)?.toDouble() ?? 0;
              if (rating > 0) {
                totalRating += rating;
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
                      final data = feedback.data() as Map<String, dynamic>;

                      return _FeedbackCard(
                        userName: data['user_name'] ?? 'Cliente',
                        rating: (data['rating'] as num?)?.toDouble() ?? 0,
                        comment: data['comment'] ?? '',
                        category: data['category'] ?? '',
                        createdAt: data['created_at'] as Timestamp?,
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
  final String userName;
  final double rating;
  final String comment;
  final String category;
  final Timestamp? createdAt;

  const _FeedbackCard({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.category,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateStr = createdAt != null
        ? dateFormat.format(createdAt!.toDate())
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
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryText,
                  ),
                ),
                Text(
                  dateStr,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RatingBarIndicator(
              rating: rating,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 20,
            ),
            if (category.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.amarelo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.amarelo,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                comment,
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
