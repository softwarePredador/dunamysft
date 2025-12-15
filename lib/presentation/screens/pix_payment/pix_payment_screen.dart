import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class PIXPaymentScreen extends StatelessWidget {
  final String orderId;

  const PIXPaymentScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    // Mock PIX code - in production, this would come from payment gateway
    const String pixCode = '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-426614174000';

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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pagamento PIX',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
            color: AppTheme.primaryText,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 140.0),
            child: Column(
              children: [
                // PIX QR Code Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Escaneie o QR Code',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      
                      // QR Code placeholder
                      Container(
                        width: 200.0,
                        height: 200.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.grayPaletteGray20),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code_2,
                            size: 150.0,
                            color: AppTheme.primaryText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      Text(
                        'ou copie o código PIX',
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          color: AppTheme.secondaryText,
                        ),
                      ),

                      const SizedBox(height: 12.0),

                      // PIX Code
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: AppTheme.grayPaletteGray10,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                pixCode,
                                style: GoogleFonts.inter(
                                  fontSize: 12.0,
                                  color: AppTheme.primaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20.0),
                              onPressed: () {
                                // Copy to clipboard
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Código PIX copiado!'),
                                    backgroundColor: AppTheme.success,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24.0),

                // Instructions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.info,
                            size: 20.0,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Como pagar com PIX',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14.0,
                              color: AppTheme.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      _buildInstruction('1', 'Abra o app do seu banco'),
                      _buildInstruction('2', 'Escolha pagar com PIX'),
                      _buildInstruction('3', 'Escaneie o QR Code ou cole o código'),
                      _buildInstruction('4', 'Confirme o pagamento'),
                    ],
                  ),
                ),

                const SizedBox(height: 24.0),

                // Timer Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: AppTheme.warning,
                        size: 24.0,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          'Este código expira em 30 minutos',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: AppTheme.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/order-done', extra: orderId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.amarelo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'Já Paguei',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.0,
            height: 20.0,
            decoration: const BoxDecoration(
              color: AppTheme.info,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                color: AppTheme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
