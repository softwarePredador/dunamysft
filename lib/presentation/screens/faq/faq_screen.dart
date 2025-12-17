import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/faq_model.dart';
import '../../providers/faq_provider.dart';
import '../../widgets/navbar_widget.dart';
import '../../widgets/end_drawer_widget.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Load FAQs
    Future.microtask(() {
      context.read<FAQProvider>().loadFAQs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.primaryBackground,
      endDrawer: const EndDrawerWidget(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // AppBar customizado
                Container(
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_left_sharp, color: AppTheme.amarelo, size: 35.0),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.tr(context).faq,
                          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48.0), // Balance for back button
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Consumer<FAQProvider>(
                    builder: (context, faqProvider, child) {
                      if (faqProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (faqProvider.error.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                              const SizedBox(height: 16),
                              Text(AppLocalizations.tr(context).get('error_loading_faq'), style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(faqProvider.error, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      }

                      final faqs = faqProvider.faqs;

                      if (faqs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.help_outline, size: 64, color: AppTheme.grayPaletteGray60),
                              const SizedBox(height: 16),
                              Text(AppLocalizations.tr(context).get('no_faq_available'), style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: faqs.length,
                        itemBuilder: (context, index) {
                          final faq = faqs[index];
                          return _FAQItem(faq: faq);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Navbar
          Align(
            alignment: Alignment.bottomCenter,
            child: NavbarWidget(onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer()),
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final FAQModel faq;

  const _FAQItem({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: const Color(0xFFCCCCCC),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
              child: Text(
                faq.question,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                child: Text(
                  faq.answer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
