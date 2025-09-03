import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/themes/app_colors.dart';

class PdfViewerPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.onSurface(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.onSurface(context),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: AppColors.onSurface(context),
            ),
            onPressed: () => _sharePdf(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (PdfPageFormat format) => pdfBytes,
        allowPrinting: true,
        allowSharing: false, // Desabilitado para usar nosso botão personalizado
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: title,
        onPrinted: (context) {
          Get.snackbar(
            'Sucesso',
            'PDF impresso com sucesso!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      // Mostrar indicador de carregamento
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Criar um nome de arquivo baseado no título
      final fileName = '${title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}.pdf';
      
      // Salvar o PDF temporariamente
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      
      // Verificar se o arquivo foi criado
      if (!await file.exists()) {
        throw Exception('Falha ao criar arquivo temporário');
      }
      
      // Fechar o dialog de carregamento
      Get.back();
      
      // Compartilhar o arquivo
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Relatório de vendas - $title',
        subject: title,
      );
      
      // Verificar se o compartilhamento foi bem-sucedido
      if (result.status == ShareResultStatus.success) {
        Get.snackbar(
          'Sucesso',
          'PDF compartilhado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (result.status == ShareResultStatus.dismissed) {
        Get.snackbar(
          'Cancelado',
          'Compartilhamento cancelado',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      
    } catch (e) {
      // Fechar o dialog de carregamento se estiver aberto
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      // Mostrar mensagem de erro
      Get.snackbar(
        'Erro',
        'Erro ao compartilhar PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
