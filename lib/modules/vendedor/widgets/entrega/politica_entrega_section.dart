import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../campo_editavel.dart';
import '../../controllers/vendor_settings_controller.dart';

class PoliticaEntregaSection extends StatelessWidget {
  final VendedorSettingsController controller;

  const PoliticaEntregaSection({
    super.key,
    required this.controller,
  });

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
              onChanged: (v) =>
                  controller.taxaEntrega.value = double.tryParse(v) ?? 0.0,
              keyboardType: TextInputType.number,
            ),
            CampoEditavel(
              label: 'Raio de entrega (km)',
              valor: controller.raioEntrega.value.toStringAsFixed(1),
              onChanged: (v) =>
                  controller.raioEntrega.value = double.tryParse(v) ?? 0.0,
              keyboardType: TextInputType.number,
            ),
            CampoEditavel(
              label: 'Limite para entrega grátis (R\$)',
              valor: controller.limiteEntregaGratis.value.toStringAsFixed(2),
              onChanged: (v) => controller.limiteEntregaGratis.value =
                  double.tryParse(v) ?? 0.0,
              keyboardType: TextInputType.number,
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
              onChanged: (v) => controller.pedidoMinimo.value =
                  double.tryParse(v) ?? 0.0,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
          ],
        ));
  }
}
