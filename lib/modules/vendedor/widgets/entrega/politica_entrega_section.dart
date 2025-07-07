import 'package:flutter/material.dart';
import '../campo_editavel.dart';
import '../../controllers/vendor_settings_controller.dart';

class PoliticaEntregaSection extends StatelessWidget {
  final VendorSettingsController controller;

  const PoliticaEntregaSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
          onChanged: (v) =>
              controller.limiteEntregaGratis.value = double.tryParse(v) ?? 0.0,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
