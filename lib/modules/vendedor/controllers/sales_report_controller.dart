import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/services/pdf_report_service.dart';
import '../../../core/models/order_model.dart';
import '../repositories/vendor_metrics_repository.dart';
import '../pages/pdf_viewer_page.dart';
import '../../../core/utils/logger.dart';
import 'package:intl/intl.dart';

class SalesReportController extends GetxController {
  final VendorMetricsRepository _metricsRepository =
      Get.find<VendorMetricsRepository>();
  final PdfReportService _pdfService = PdfReportService();

  // Estados reativos
  final RxBool _isLoading = false.obs;
  final RxBool _isGeneratingPdf = false.obs;
  final RxList<OrderModel> _allOrders = <OrderModel>[].obs;
  final Rx<DateTime?> _startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _endDate = Rx<DateTime?>(null);
  final RxString _selectedPeriod = 'Último mês'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isGeneratingPdf => _isGeneratingPdf.value;
  List<OrderModel> get allOrders => _allOrders;
  DateTime? get startDate => _startDate.value;
  DateTime? get endDate => _endDate.value;
  String get selectedPeriod => _selectedPeriod.value;

  // Períodos pré-definidos
  final List<Map<String, dynamic>> predefinedPeriods = [
    {'label': 'Última semana', 'days': 7},
    {'label': 'Último mês', 'days': 30},
    {'label': 'Últimos 3 meses', 'days': 90},
    {'label': 'Últimos 6 meses', 'days': 180},
    {'label': 'Último ano', 'days': 365},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
    _setDefaultPeriod();
  }

  /// Carrega todos os pedidos do vendedor
  Future<void> _loadOrders() async {
    _isLoading.value = true;
    try {
      // Buscar todos os pedidos do vendedor
      final orders = await _metricsRepository.getAllOrders();
      _allOrders.value = orders;
      AppLogger.info('📊 [SALES_REPORT] ${orders.length} pedidos carregados');
    } catch (e) {
      AppLogger.error('Erro ao carregar pedidos para relatório', e);
      Get.snackbar(
        'Erro',
        'Erro ao carregar pedidos: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Define período padrão (último mês)
  void _setDefaultPeriod() {
    final now = DateTime.now();
    _endDate.value = now;
    _startDate.value = now.subtract(const Duration(days: 30));
    _selectedPeriod.value = 'Último mês';
  }

  /// Seleciona um período pré-definido
  void selectPredefinedPeriod(String periodLabel) {
    final period = predefinedPeriods.firstWhere(
      (p) => p['label'] == periodLabel,
      orElse: () => {'label': 'Último mês', 'days': 30},
    );

    final now = DateTime.now();
    _endDate.value = now;
    _startDate.value = now.subtract(Duration(days: period['days']));
    _selectedPeriod.value = periodLabel;
  }

  /// Define período personalizado
  void setCustomPeriod(DateTime start, DateTime end) {
    _startDate.value = start;
    _endDate.value = end;
    _selectedPeriod.value = 'Personalizado';
  }

  /// Filtra pedidos pelo período selecionado
  List<OrderModel> getFilteredOrders() {
    if (_startDate.value == null || _endDate.value == null) {
      return _allOrders;
    }

    return _allOrders.where((order) {
      final orderDate = order.createdAt;
      return orderDate.isAfter(_startDate.value!) &&
          orderDate.isBefore(_endDate.value!.add(const Duration(days: 1)));
    }).toList();
  }

  /// Atualiza um pedido específico no relatório quando seu status for alterado
  void updateOrderInReport(OrderModel updatedOrder) {
    try {
      // Encontrar o índice do pedido na lista
      final index =
          _allOrders.indexWhere((order) => order.id == updatedOrder.id);

      if (index != -1) {
        // Atualizar o pedido na lista
        _allOrders[index] = updatedOrder;

        AppLogger.info(
            '✅ [SALES_REPORT] Pedido ${updatedOrder.id} atualizado no relatório');
      } else {
        AppLogger.warning(
            '⚠️ [SALES_REPORT] Pedido ${updatedOrder.id} não encontrado no relatório');
      }
    } catch (e) {
      AppLogger.error(
          '❌ [SALES_REPORT] Erro ao atualizar pedido no relatório', e);
    }
  }

  /// Calcula estatísticas do período
  Map<String, dynamic> getPeriodStats() {
    final filteredOrders = getFilteredOrders();

    if (filteredOrders.isEmpty) {
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'averageOrderValue': 0.0,
        'totalItems': 0,
      };
    }

    final totalRevenue =
        filteredOrders.fold<double>(0.0, (sum, order) => sum + order.total);
    final totalItems = filteredOrders.fold<int>(
        0,
        (sum, order) =>
            sum +
            order.items
                .fold<int>(0, (itemSum, item) => itemSum + item.quantity));

    return {
      'totalOrders': filteredOrders.length,
      'totalRevenue': totalRevenue,
      'averageOrderValue': totalRevenue / filteredOrders.length,
      'totalItems': totalItems,
    };
  }

  /// Gera e compartilha o relatório em PDF
  Future<void> generateAndShareReport() async {
    if (_startDate.value == null || _endDate.value == null) {
      Get.snackbar(
        'Erro',
        'Selecione um período válido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    _isGeneratingPdf.value = true;

    try {
      final filteredOrders = getFilteredOrders();

      if (filteredOrders.isEmpty) {
        Get.snackbar(
          'Aviso',
          'Nenhum pedido encontrado no período selecionado',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Gerar nome do arquivo
      final startDateStr = DateFormat('ddMMyyyy').format(_startDate.value!);
      final endDateStr = DateFormat('ddMMyyyy').format(_endDate.value!);
      final fileName = 'relatorio_vendas_${startDateStr}_${endDateStr}.pdf';

      // Gerar PDF
      final pdfBytes = await _pdfService.generateSalesReport(
        orders: filteredOrders,
        startDate: _startDate.value!,
        endDate: _endDate.value!,
        storeName: 'Minha Loja', // TODO: Buscar nome da loja das configurações
      );

      // Compartilhar PDF
      await _pdfService.sharePdf(pdfBytes, fileName);

      Get.snackbar(
        'Sucesso',
        'Relatório gerado e compartilhado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      AppLogger.error('Erro ao gerar relatório', e);
      Get.snackbar(
        'Erro',
        'Erro ao gerar relatório: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      _isGeneratingPdf.value = false;
    }
  }

  /// Visualiza o relatório em PDF no app
  Future<void> previewReport() async {
    if (_startDate.value == null || _endDate.value == null) {
      Get.snackbar(
        'Erro',
        'Selecione um período válido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    _isGeneratingPdf.value = true;

    try {
      final filteredOrders = getFilteredOrders();

      if (filteredOrders.isEmpty) {
        Get.snackbar(
          'Aviso',
          'Nenhum pedido encontrado no período selecionado',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Gerar PDF
      final pdfBytes = await _pdfService.generateSalesReport(
        orders: filteredOrders,
        startDate: _startDate.value!,
        endDate: _endDate.value!,
        storeName: 'Minha Loja', // TODO: Buscar nome da loja das configurações
      );

      // Visualizar PDF na página dedicada
      final title =
          'Relatório de Vendas - ${DateFormat('dd/MM/yyyy').format(_startDate.value!)} a ${DateFormat('dd/MM/yyyy').format(_endDate.value!)}';
      Get.to(() => PdfViewerPage(
            pdfBytes: pdfBytes,
            title: title,
          ));
    } catch (e) {
      AppLogger.error('Erro ao visualizar relatório', e);
      Get.snackbar(
        'Erro',
        'Erro ao visualizar relatório: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      _isGeneratingPdf.value = false;
    }
  }

  /// Atualiza os dados do relatório
  Future<void> refreshData() async {
    await _loadOrders();
  }

  /// Formata data para exibição
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formata valor monetário
  String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ').format(value);
  }
}
