import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/feedback_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/feedback_service.dart';
import '../../widgets/navbar_widget.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _rating = 0.0;
  String? _selectedChip;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  final List<String> _feedbackOptions = [
    '😃 Gostei',
    '😔 Atendimento ruim',
    '🏓 Sala de jogos',
    '🤑 Bom preço',
    '🛌🏼 Bom para dormir',
    '💦 Piscina boa',
    '🍔 Comida boa',
    '💪🏽 Academia',
    '🧹 Limpeza',
    '🤝 Bom para reuniões',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para enviar feedback')),
      );
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma avaliação')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final feedbackService = FeedbackService();
      final feedback = FeedbackModel(
        id: '',
        userId: user.uid,
        emotion: _selectedChip ?? '',
        ranking: _rating.round(),
        obs: _commentController.text,
      );
      
      final success = await feedbackService.submitFeedback(feedback);

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Obrigado pelo seu feedback!'),
              backgroundColor: AppTheme.success,
            ),
          );
          context.go('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao enviar feedback. Tente novamente.')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar feedback: $e')),
        );
      }
    }
  }

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
      body: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 115.0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Feedback',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color: AppTheme.primaryText,
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // Question
                  Text(
                    'Queremos saber como foi sua estadia no Dunamys Hotel?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 22.0,
                      color: AppTheme.primaryText,
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // Feedback Options (Choice Chips)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _feedbackOptions.map((option) {
                      final isSelected = _selectedChip == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedChip = selected ? option : null;
                          });
                        },
                        selectedColor: AppTheme.amarelo,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.primaryText,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          side: BorderSide(
                            color: isSelected ? AppTheme.amarelo : const Color(0xFFCCCCCC),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30.0),

                  // Rating Section
                  Text(
                    'Como você avalia sua experiência?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color: AppTheme.primaryText,
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  Center(
                    child: RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 50.0,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: AppTheme.amarelo,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() => _rating = rating);
                      },
                    ),
                  ),

                  const SizedBox(height: 30.0),

                  // Comment Section
                  Text(
                    'Gostaria de deixar um comentário?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color: AppTheme.primaryText,
                    ),
                  ),

                  const SizedBox(height: 12.0),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: AppTheme.grayPaletteGray20,
                        width: 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Escreva seu comentário aqui...',
                        hintStyle: GoogleFonts.inter(
                          color: AppTheme.grayPaletteGray60,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30.0),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.amarelo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24.0,
                              width: 24.0,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                          : Text(
                              'Enviar Feedback',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navbar
          const Align(
            alignment: Alignment.bottomCenter,
            child: NavbarWidget(),
          ),
        ],
      ),
    );
  }
}
