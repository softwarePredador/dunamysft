import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_theme.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  List<Map<String, dynamic>>? _reportData;

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryText,
              onPrimary: Colors.white,
              surface: AppTheme.secondaryBackground,
              onSurface: AppTheme.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryText,
              onPrimary: Colors.white,
              surface: AppTheme.secondaryBackground,
              onSurface: AppTheme.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _generateReport() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione a Data Início')));
      return;
    }
    if (_endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione a Data Fim')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ajustar endDate para incluir todo o dia
      final endOfDay = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        23,
        59,
        59,
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('order')
          .where(
            'created_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!),
          )
          .where(
            'created_at',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          )
          .orderBy('created_at', descending: true)
          .get();

      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();

      setState(() => _reportData = orders);

      if (orders.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum pedido encontrado no período'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao gerar relatório: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportCSV() async {
    if (_reportData == null || _reportData!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum dado para exportar')),
      );
      return;
    }

    try {
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
      final buffer = StringBuffer();

      // BOM UTF-8 para Excel reconhecer acentos corretamente
      buffer.write('\uFEFF');

      // Header com separador ; (padrão pt-BR Excel)
      buffer.writeln(
        'Codigo;Quarto;Cliente;CPF;Total;Entrega;Status;Pagamento;Status Pagamento;Data',
      );

      // Data
      for (final order in _reportData!) {
        final createdAt = order['created_at'] as Timestamp?;
        final dateStr = createdAt != null
            ? dateFormat.format(createdAt.toDate())
            : '';

        // Tratamento seguro de campos
        final codigo = order['codigo'] ?? '';
        final room = _escapeCsvField(order['room']?.toString() ?? '');
        final customerName = _escapeCsvField(
          order['customerName']?.toString() ?? '',
        );
        final customerCpf = _escapeCsvField(
          order['customerCpf']?.toString() ?? '',
        );
        final total = (order['total'] as num?)?.toDouble() ?? 0.0;
        final totalFormatted = total
            .toStringAsFixed(2)
            .replaceAll('.', ','); // Formato BR
        final retirar = order['retirar'] == true;
        final deliveryType = retirar ? 'Retirada' : 'Entrega';
        final status = _translateStatus(order['status']?.toString() ?? '');
        final paymentMethod = _translatePayment(
          order['paymentMethod']?.toString() ??
              order['payment']?.toString() ??
              '',
        );
        final paymentStatus = _translatePaymentStatus(
          order['paymentStatus']?.toString() ?? '',
        );

        buffer.writeln(
          '$codigo;'
          '$room;'
          '$customerName;'
          '$customerCpf;'
          '$totalFormatted;'
          '$deliveryType;'
          '$status;'
          '$paymentMethod;'
          '$paymentStatus;'
          '$dateStr',
        );
      }

      // Salvar arquivo com data no nome
      final directory = await getTemporaryDirectory();
      final fileName =
          'relatorio_pedidos_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(buffer.toString());

      // Compartilhar
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Relatório de Pedidos - Hotel Dunamys',
        text:
            'Relatório de pedidos de ${DateFormat('dd/MM/yyyy').format(_startDate!)} a ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao exportar: $e')));
      }
    }
  }

  String _escapeCsvField(String value) {
    // Se contiver ; ou " ou quebra de linha, precisa escapar
    if (value.contains(';') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendente';
      case 'preparando':
        return 'Preparando';
      case 'pronto':
        return 'Pronto';
      case 'entregue':
        return 'Entregue';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String _translatePayment(String payment) {
    switch (payment.toLowerCase()) {
      case 'pix':
        return 'PIX';
      case 'credit':
      case 'credito':
        return 'Crédito';
      case 'debit':
      case 'debito':
        return 'Débito';
      case 'cash':
      case 'dinheiro':
        return 'Dinheiro';
      default:
        return payment;
    }
  }

  String _translatePaymentStatus(String status) {
    if (status.isEmpty) return '-';
    switch (status.toLowerCase()) {
      case 'approved':
      case 'paid':
        return 'Aprovado';
      case 'pending':
        return 'Pendente';
      case 'denied':
      case 'rejected':
        return 'Negado';
      case 'refunded':
        return 'Estornado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

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
          'Relatórios',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Selecione o Período',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 30),

              // Data Início
              InkWell(
                onTap: _selectStartDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryText.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppTheme.primaryText,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Data Início',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryText,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _startDate != null
                            ? dateFormat.format(_startDate!)
                            : '--/--/----',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Data Fim
              InkWell(
                onTap: _selectEndDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryText.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppTheme.primaryText,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Data Fim',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryText,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _endDate != null
                            ? dateFormat.format(_endDate!)
                            : '--/--/----',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Botão Gerar
              Center(
                child: InkWell(
                  onTap: _isLoading ? null : _generateReport,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 220,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryText,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Gerar Relatório',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.secondaryBackground,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              // Resultado do Relatório
              if (_reportData != null) ...[
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Resultado: ${_reportData!.length} pedidos',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    if (_reportData!.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: AppTheme.adminAccent,
                        ),
                        onPressed: _exportCSV,
                        tooltip: 'Exportar CSV',
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Resumo
                if (_reportData!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.adminAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Total Vendido',
                          'R\$ ${_calculateTotal().toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Ticket Médio',
                          'R\$ ${_calculateAverage().toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Finalizados',
                          '${_countByStatus('entregue')}',
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Cancelados',
                          '${_countByStatus('cancelado')}',
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Lista de pedidos
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _reportData!.length,
                  itemBuilder: (context, index) {
                    final order = _reportData![index];
                    final createdAt = order['created_at'] as Timestamp?;
                    final dateStr = createdAt != null
                        ? DateFormat('dd/MM HH:mm').format(createdAt.toDate())
                        : '';

                    return ListTile(
                      title: Text('Quarto ${order['room'] ?? 'N/A'}'),
                      subtitle: Text(dateStr),
                      trailing: Text(
                        'R\$ ${(order['total'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () => context.push('/admin/orders/${order['id']}'),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.primaryText),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
      ],
    );
  }

  double _calculateTotal() {
    if (_reportData == null) return 0;
    return _reportData!.fold(0.0, (sum, order) {
      return sum + ((order['total'] as num?)?.toDouble() ?? 0);
    });
  }

  double _calculateAverage() {
    if (_reportData == null || _reportData!.isEmpty) return 0;
    return _calculateTotal() / _reportData!.length;
  }

  int _countByStatus(String status) {
    if (_reportData == null) return 0;
    return _reportData!.where((order) => order['status'] == status).length;
  }
}
