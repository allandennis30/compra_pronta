import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';

class PdfReportService {
  static final PdfReportService _instance = PdfReportService._internal();
  factory PdfReportService() => _instance;
  PdfReportService._internal();

  /// Gera um relatório de vendas em PDF
  Future<Uint8List> generateSalesReport({
    required List<OrderModel> orders,
    required DateTime startDate,
    required DateTime endDate,
    String? storeName,
  }) async {
    final pdf = pw.Document();

    // Filtrar pedidos por período
    final filteredOrders = orders.where((order) {
      return order.createdAt
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          order.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Calcular totais
    final totalOrders = filteredOrders.length;
    final totalRevenue =
        filteredOrders.fold<double>(0.0, (sum, order) => sum + order.total);

    // Agrupar por mês
    final ordersByMonth = <String, List<OrderModel>>{};
    for (final order in filteredOrders) {
      final monthKey = DateFormat('MM/yyyy').format(order.createdAt);
      ordersByMonth.putIfAbsent(monthKey, () => []).add(order);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(storeName ?? 'Minha Loja', startDate, endDate),
            pw.SizedBox(height: 20),
            _buildSummary(totalOrders, totalRevenue),
            pw.SizedBox(height: 20),
            ..._buildMonthlyReports(ordersByMonth),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Cabeçalho do relatório
  pw.Widget _buildHeader(
      String storeName, DateTime startDate, DateTime endDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Relatório de Vendas',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          storeName,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Período: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
          style: const pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Gerado em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  /// Resumo geral
  pw.Widget _buildSummary(int totalOrders, double totalRevenue) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Column(
            children: [
              pw.Text(
                'Total de Pedidos',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                totalOrders.toString(),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ],
          ),
          pw.Column(
            children: [
              pw.Text(
                'Receita Total',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(totalRevenue)}',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Relatórios por mês
  List<pw.Widget> _buildMonthlyReports(
      Map<String, List<OrderModel>> ordersByMonth) {
    final widgets = <pw.Widget>[];

    // Ordenar meses
    final sortedMonths = ordersByMonth.keys.toList()
      ..sort((a, b) {
        final aParts = a.split('/');
        final bParts = b.split('/');
        final aDate = DateTime(int.parse(aParts[1]), int.parse(aParts[0]));
        final bDate = DateTime(int.parse(bParts[1]), int.parse(bParts[0]));
        return aDate.compareTo(bDate);
      });

    for (final month in sortedMonths) {
      final monthOrders = ordersByMonth[month]!;
      final monthRevenue =
          monthOrders.fold<double>(0.0, (sum, order) => sum + order.total);

      widgets.addAll([
        pw.SizedBox(height: 20),
        _buildMonthHeader(month, monthOrders.length, monthRevenue),
        pw.SizedBox(height: 12),
        _buildOrdersTable(monthOrders),
      ]);
    }

    return widgets;
  }

  /// Cabeçalho do mês
  pw.Widget _buildMonthHeader(String month, int orderCount, double revenue) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Mês: $month',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Row(
            children: [
              pw.Text(
                '$orderCount pedidos',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(width: 20),
              pw.Text(
                'R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(revenue)}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tabela de pedidos
  pw.Widget _buildOrdersTable(List<OrderModel> orders) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FixedColumnWidth(40), // Número
        1: const pw.FixedColumnWidth(80), // Data
        2: const pw.FlexColumnWidth(2), // Cliente
        3: const pw.FlexColumnWidth(3), // Itens
        4: const pw.FixedColumnWidth(60), // Total
      },
      children: [
        // Cabeçalho da tabela
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('#', isHeader: true),
            _buildTableCell('Data', isHeader: true),
            _buildTableCell('Cliente', isHeader: true),
            _buildTableCell('Itens', isHeader: true),
            _buildTableCell('Total', isHeader: true),
          ],
        ),
        // Linhas dos pedidos
        ...orders.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final order = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell(index.toString()),
              _buildTableCell(DateFormat('dd/MM').format(order.createdAt)),
              _buildTableCell(order.clientName ?? 'Cliente não informado'),
              _buildTableCell(_formatOrderItems(order.items)),
              _buildTableCell(
                'R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(order.total)}',
                isNumeric: true,
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Célula da tabela
  pw.Widget _buildTableCell(String text,
      {bool isHeader = false, bool isNumeric = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.black : PdfColors.grey800,
        ),
        textAlign: isNumeric ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  /// Formatar itens do pedido
  String _formatOrderItems(List<OrderItemModel> items) {
    if (items.isEmpty) return 'Nenhum item';

    final itemTexts = items.map((item) {
      return '${item.quantity}x ${item.productName}';
    }).toList();

    return itemTexts.join(', ');
  }

  /// Compartilha o PDF gerado
  Future<void> sharePdf(Uint8List pdfBytes, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Relatório de vendas - $fileName',
      );
    } catch (e) {
      throw Exception('Erro ao compartilhar PDF: $e');
    }
  }

  /// Visualiza o PDF no app
  Future<void> previewPdf(Uint8List pdfBytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
    );
  }

  /// Salva o PDF no dispositivo
  Future<String> savePdf(Uint8List pdfBytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      throw Exception('Erro ao salvar PDF: $e');
    }
  }
}
