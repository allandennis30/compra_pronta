import 'package:flutter/material.dart';
import '../campo_editavel.dart';
import '../../controllers/vendor_settings_controller.dart';

class PerfilLojaSection extends StatelessWidget {
  final VendorSettingsController controller;

  const PerfilLojaSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Perfil da Loja', style: Theme.of(context).textTheme.titleLarge),
        CampoEditavel(
          label: 'Nome da Loja',
          valor: controller.nomeLoja.value,
          onChanged: (v) => controller.nomeLoja.value = v,
        ),
        CampoEditavel(
          label: 'CNPJ/CPF',
          valor: controller.cnpjCpf.value,
          onChanged: (v) => controller.cnpjCpf.value = v,
        ),
        CampoEditavel(
          label: 'Descrição',
          valor: controller.descricao.value,
          onChanged: (v) => controller.descricao.value = v,
          maxLines: 2,
        ),
        CampoEditavel(
          label: 'Endereço',
          valor: controller.endereco.value,
          onChanged: (v) => controller.endereco.value = v,
        ),
        CampoEditavel(
          label: 'Telefone',
          valor: controller.telefone.value,
          onChanged: (v) => controller.telefone.value = v,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
