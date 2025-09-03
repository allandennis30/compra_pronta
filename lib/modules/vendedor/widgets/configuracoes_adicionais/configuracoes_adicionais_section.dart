import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../campo_editavel.dart';
import '../../controllers/vendor_settings_controller.dart';

class ConfiguracoesAdicionaisSection extends StatelessWidget {
  final VendedorSettingsController controller;

  const ConfiguracoesAdicionaisSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configurações Adicionais',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Categoria da loja
            CampoEditavel(
              label: 'Categoria da Loja',
              valor: controller.categoriaLoja.value,
              onChanged: (v) => controller.categoriaLoja.value = v,
            ),
            
            const SizedBox(height: 16),
            
            // Métodos de pagamento aceitos
            Text('Métodos de Pagamento Aceitos',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            
            // Checkboxes para métodos de pagamento
            CheckboxListTile(
              title: const Text('Aceita Cartão'),
              subtitle: const Text('Cartão de crédito e débito'),
              value: controller.aceitaCartao.value,
              onChanged: (value) => controller.aceitaCartao.value = value ?? false,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            
            CheckboxListTile(
              title: const Text('Aceita Dinheiro'),
              subtitle: const Text('Pagamento em dinheiro'),
              value: controller.aceitaDinheiro.value,
              onChanged: (value) => controller.aceitaDinheiro.value = value ?? false,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            
            CheckboxListTile(
              title: const Text('Aceita PIX'),
              subtitle: const Text('Pagamento via PIX'),
              value: controller.aceitaPix.value,
              onChanged: (value) => controller.aceitaPix.value = value ?? false,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            
            const SizedBox(height: 16),
            
            // Status da loja
            Text('Status da Loja',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            
            SwitchListTile(
              title: const Text('Loja Ativa'),
              subtitle: const Text('Loja está funcionando e aceitando pedidos'),
              value: controller.ativo.value,
              onChanged: (value) => controller.ativo.value = value,
              secondary: Icon(
                controller.ativo.value ? Icons.store : Icons.store_mall_directory_outlined,
                color: controller.ativo.value ? Colors.green : Colors.grey,
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ));
  }
}
