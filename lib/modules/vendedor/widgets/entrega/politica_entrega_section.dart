import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../campo_editavel.dart';
import '../../controllers/vendor_settings_controller.dart';

class PoliticaEntregaSection extends StatelessWidget {
  final VendedorSettingsController controller;

  const PoliticaEntregaSection({
    super.key,
    required this.controller,
  });

  String _formatCurrencyBr(String raw) {
    if (raw.trim().isEmpty) return '';
    // Sanitize and parse
    var s = raw.replaceAll(RegExp(r'[^0-9,.-]'), '');
    if (s.contains(',') && s.contains('.')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains(',')) {
      s = s.replaceAll(',', '.');
    }
    final value = double.tryParse(s);
    if (value == null) return raw;
    final f = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return f.format(value);
  }

  String _formatDecimalBr(String raw) {
    if (raw.trim().isEmpty) return '';
    final normalized = raw.replaceAll('.', '').replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null) return raw;
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceAll('.', ',');
  }

  String _formatKm(String raw) {
    if (raw.trim().isEmpty) return '';
    final normalized = raw.replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null) return raw;
    final fixed = value.toStringAsFixed(1);
    return fixed.replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Política de Entrega',
                style: Theme.of(context).textTheme.titleLarge),
            CampoEditavel(
              label: 'Taxa de entrega (R\$)',
              valor: controller.taxaEntrega.value.toStringAsFixed(2),
              onChanged: (v) {
                // Sanitize input to handle previously formatted currency string
                var s = v.replaceAll(RegExp(r'[^0-9,.-]'), '');
                if (s.isEmpty || s == '.' || s == '-' || s == ',') {
                  return;
                }
                if (s.contains(',') && s.contains('.')) {
                  s = s.replaceAll('.', '').replaceAll(',', '.');
                } else if (s.contains(',')) {
                  s = s.replaceAll(',', '.');
                }
                final parsed = double.tryParse(s);
                if (parsed != null) {
                  controller.taxaEntrega.value = parsed;
                }
              },
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onBlurFormat: _formatCurrencyBr,
            ),
            CampoEditavel(
              label: 'Raio de entrega (km)',
              valor: controller.raioEntrega.value.toStringAsFixed(1),
              onChanged: (v) {
                final normalized = v.replaceAll(',', '.');
                if (normalized.isEmpty ||
                    normalized == '.' ||
                    normalized == '-') {
                  return;
                }
                final parsed = double.tryParse(normalized);
                if (parsed != null) {
                  controller.raioEntrega.value = parsed;
                }
              },
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onBlurFormat: _formatKm,
            ),
            CampoEditavel(
              label: 'Limite para entrega grátis (R\$)',
              valor: controller.limiteEntregaGratis.value.toStringAsFixed(2),
              onChanged: (v) {
                final normalized = v.replaceAll(',', '.');
                if (normalized.isEmpty ||
                    normalized == '.' ||
                    normalized == '-') {
                  return;
                }
                final parsed = double.tryParse(normalized);
                if (parsed != null) {
                  controller.limiteEntregaGratis.value = parsed;
                }
              },
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onBlurFormat: _formatDecimalBr,
            ),
            Row(
              children: [
                Expanded(
                  child: CampoEditavel(
                    label: 'Tempo min. entrega (min)',
                    valor: controller.tempoEntregaMin.value.toString(),
                    onChanged: (v) => controller.tempoEntregaMin.value =
                        int.tryParse(v) ?? 30,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CampoEditavel(
                    label: 'Tempo max. entrega (min)',
                    valor: controller.tempoEntregaMax.value.toString(),
                    onChanged: (v) => controller.tempoEntregaMax.value =
                        int.tryParse(v) ?? 60,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            CampoEditavel(
              label: 'Pedido mínimo (R\$)',
              valor: controller.pedidoMinimo.value.toStringAsFixed(2),
              onChanged: (v) {
                final normalized = v.replaceAll(',', '.');
                if (normalized.isEmpty ||
                    normalized == '.' ||
                    normalized == '-') {
                  return;
                }
                final parsed = double.tryParse(normalized);
                if (parsed != null) {
                  controller.pedidoMinimo.value = parsed;
                }
              },
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onBlurFormat: _formatDecimalBr,
            ),
            const SizedBox(height: 16),
          ],
        ));
  }
}
