import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../campo_editavel.dart';
import '../../controllers/vendor_settings_controller.dart';
import 'endereco_widget.dart';

class PerfilLojaSection extends StatelessWidget {
  final VendedorSettingsController controller;

  const PerfilLojaSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Perfil da Loja',
                style: Theme.of(context).textTheme.titleLarge),
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
            // Widget de endereço com funcionalidade de CEP
            EnderecoWidget(controller: controller),
            CampoEditavel(
              label: 'Telefone',
              valor: controller.telefone.value,
              onChanged: (v) => controller.telefone.value = v,
            ),
            const SizedBox(height: 16),
          ],
        ));
  }
}
