// Automatic FlutterFlow imports
import '/backend/backend.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'dart:html' as html; // Removido para compatibilidade multiplataforma
import 'package:intl/intl.dart'; // Para formatação de data

Future downloadOrdersReportCSV(List<DocumentReference> orderDocRefs) async {
  // Cabeçalho do CSV
  String fileContent = "Data Pedido,Nome Produto,Quantidade,Total Produto";

  // Formatador de data
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  for (var orderRef in orderDocRefs) {
    // Buscar o documento do pedido (OrderRecord)
    OrderRecord? orderDoc = await OrderRecord.getDocumentOnce(orderRef);

    if (orderDoc != null) {
      // Obter a data do pedido
      String orderDateStr =
          orderDoc.date != null ? dateFormatter.format(orderDoc.date!) : 'N/A';

      // Buscar os produtos associados à ordem
      List<OrderProductsRecord> orderProductsList =
          await queryOrderProductsRecordOnce(
        queryBuilder: (query) => query.where('order', isEqualTo: orderRef),
      );

      for (var orderProductDoc in orderProductsList) {
        String productName = 'Produto Desconhecido';
        String quantityStr = orderProductDoc.quantity?.toString() ?? '0';
        String productTotalStr = orderProductDoc.total != null
            ? orderProductDoc.total!.toStringAsFixed(2)
            : '0.00';

        // Buscar o documento do menu (MenuRecord)
        if (orderProductDoc.product != null) {
          MenuRecord? menuDoc =
              await MenuRecord.getDocumentOnce(orderProductDoc.product!);
          if (menuDoc != null) {
            productName = menuDoc.name ?? 'Nome Indisponível';
          }
        }

        // Adicionar linha ao CSV
        fileContent +=
            "\n$orderDateStr,\"${productName.replaceAll('"', '""')}\",$quantityStr,$productTotalStr";
      }
    }
  }

  final fileName =
      "Relatorio_Pedidos_${dateFormatter.format(DateTime.now())}.csv";
  
  if (kIsWeb) {
    // Lógica para Web (se necessário, usar dart:html condicionalmente ou bibliotecas universais)
    // Como dart:html não compila em Windows, para Web precisaríamos de uma implementação separada
    // ou usar 'universal_html'. Por enquanto, vamos focar em corrigir o erro de compilação.
    print('Download CSV not fully implemented for Web in this hybrid mode yet.');
  } else {
    // Lógica para Mobile/Desktop
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsString(fileContent);
    
    // Abrir o arquivo (opcional, depende do que você quer fazer)
    // await launchUrl(Uri.file(path)); 
    print('CSV salvo em: $path');
  }
}
