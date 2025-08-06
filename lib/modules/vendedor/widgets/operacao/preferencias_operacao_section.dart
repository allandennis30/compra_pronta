import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../campo_editavel.dart';
import '../../controllers/vendor_settings_controller.dart';
import '../../models/horario_funcionamento.dart';

class PreferenciasOperacaoSection extends StatelessWidget {
  final VendedorSettingsController controller;

  const PreferenciasOperacaoSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferências de Operação',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),

        // Horários por dia da semana
        Text('Horários de Funcionamento:',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),

        // Dias da semana
        Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.horariosFuncionamento.length,
              itemBuilder: (context, index) {
                final diaDaSemana = _getDiaSemana(index);
                final horario = controller.horariosFuncionamento[index];

                return _buildDiaSemanaHorarios(
                  context,
                  diaDaSemana,
                  horario.horarioInicio,
                  horario.horarioFim,
                  () => controller.selecionarHorarioPorDia(index),
                  horario.ativo,
                  () => controller.toggleDiaAtivo(index),
                );
              },
            )),

        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: controller.copiarHorarioParaTodosDias,
          icon: const Icon(Icons.copy),
          label: const Text('Aplicar horário para todos os dias'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(40),
          ),
        ),
        const SizedBox(height: 16),

        // Outros campos existentes
        SwitchListTile(
          title: const Text('Aceita pedidos fora do horário?'),
          value: controller.aceitaForaHorario.value,
          onChanged: (v) => controller.aceitaForaHorario.value = v,
        ),
        CampoEditavel(
          label: 'Tempo médio de preparo (min)',
          valor: controller.tempoPreparo.value.toString(),
          onChanged: (v) =>
              controller.tempoPreparo.value = int.tryParse(v) ?? 0,
          keyboardType: TextInputType.number,
        ),
        CampoEditavel(
          label: 'Mensagem de boas-vindas',
          valor: controller.mensagemBoasVindas.value,
          onChanged: (v) => controller.mensagemBoasVindas.value = v,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getDiaSemana(int index) {
    switch (index) {
      case 0:
        return 'Segunda-feira';
      case 1:
        return 'Terça-feira';
      case 2:
        return 'Quarta-feira';
      case 3:
        return 'Quinta-feira';
      case 4:
        return 'Sexta-feira';
      case 5:
        return 'Sábado';
      case 6:
        return 'Domingo';
      default:
        return '';
    }
  }

  Widget _buildDiaSemanaHorarios(
    BuildContext context,
    String diaSemana,
    TimeOfDay horaInicio,
    TimeOfDay horaFim,
    VoidCallback onPress,
    bool ativo,
    VoidCallback onToggle,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                diaSemana,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ativo ? Colors.black : Colors.grey,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Início: ${horaInicio.format(context)}',
                style: TextStyle(color: ativo ? Colors.black : Colors.grey),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Fim: ${horaFim.format(context)}',
                style: TextStyle(color: ativo ? Colors.black : Colors.grey),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: ativo ? onPress : null,
              tooltip: 'Selecionar horário',
              color: ativo ? null : Colors.grey,
            ),
            IconButton(
              icon: Icon(ativo ? Icons.toggle_on : Icons.toggle_off),
              onPressed: onToggle,
              tooltip: ativo ? 'Desativar dia' : 'Ativar dia',
              color: ativo ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
