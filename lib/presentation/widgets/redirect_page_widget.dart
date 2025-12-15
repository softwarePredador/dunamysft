import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class RedirectPageWidget extends StatelessWidget {
  const RedirectPageWidget({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0x59000000),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
            child: Text(
              'Você será redirecionado para \na área de reservas em nosso site.\nDeseja continuar?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Voltar Button
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 130.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(65.0),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Voltar',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Ir para site Button
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  await _launchURL('https://dunamyshotel.com.br/');
                },
                child: Container(
                  width: 130.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(65.0),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ir para site',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 18.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
