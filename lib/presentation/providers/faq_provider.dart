import 'package:flutter/material.dart';
import '../../data/models/faq_model.dart';
import '../../data/services/faq_service.dart';

class FAQProvider with ChangeNotifier {
  final FAQService _faqService = FAQService();
  
  List<FAQModel> _faqs = [];
  bool _isLoading = false;
  String _error = '';

  List<FAQModel> get faqs => _faqs;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Load all FAQs
  void loadFAQs() {
    _isLoading = true;
    notifyListeners();

    _faqService.getFAQs().listen(
      (faqs) {
        _faqs = faqs;
        _isLoading = false;
        _error = '';
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Get FAQ by id
  Future<FAQModel?> getFAQ(String id) async {
    return await _faqService.getFAQ(id);
  }
}
