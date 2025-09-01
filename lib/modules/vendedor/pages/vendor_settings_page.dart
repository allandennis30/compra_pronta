import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_settings_controller.dart';
import '../widgets/card_resumo_vendas.dart';
import '../widgets/botao_logout.dart';
import '../widgets/perfil_loja/perfil_loja_section.dart';
import '../widgets/operacao/preferencias_operacao_section.dart';
import '../widgets/entrega/politica_entrega_section.dart';
import '../widgets/sincronizacao/sincronizacao_loja_section.dart';
import '../widgets/vendedor_layout.dart';

class VendorSettingsPage extends GetView<VendedorSettingsController> {
  const VendorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isVendor) {
        return Scaffold(
          appBar: AppBar(title: const Text('Configurações da Loja')),
          body: const Center(child: Text('Acesso restrito.')),
        );
      }

      return VendedorLayout(
        currentIndex: 3,
        child: Scaffold(
          appBar: AppBar(title: const Text('Configurações da Loja')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Informações da Loja
                PerfilLojaSection(controller: controller),

                const Divider(thickness: 1.5, height: 32),

                // 2. Preferências de Operação
                PreferenciasOperacaoSection(controller: controller),

                const Divider(thickness: 1.5, height: 32),

                // 3. Política de Entrega
                PoliticaEntregaSection(controller: controller),

                const Divider(thickness: 1.5, height: 32),

                // 4. Exportação de Dados
                CardResumoVendas(
                  vendasDia: controller.vendasDia.value,
                  vendasSemana: controller.vendasSemana.value,
                  vendasMes: controller.vendasMes.value,
                  totalAcumulado: controller.totalAcumulado.value,
                  onExportar: controller.exportarRelatorioVendas,
                  onCompartilhar: controller.enviarRelatorioPorWhatsappOuEmail,
                ),

                const Divider(thickness: 1.5, height: 32),

                // 5. Segurança e Sessão
                BotaoLogout(
                  onLogout: controller.logout,
                  onAlterarSenha: controller.alterarSenha,
                ),

                const Divider(thickness: 1.5, height: 32),

                // 6. Sincronização e Configurações Offline
                SincronizacaoLojaSection(controller: controller),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: controller.salvarDadosLoja,
            tooltip: 'Salvar Configurações',
            child: const Icon(Icons.save),
          ),
        ),
      );
    });
  }
}
