import 'package:flutter/material.dart';

class CardResumoVendas extends StatelessWidget {
  final double vendasDia;
  final double vendasSemana;
  final double vendasMes;
  final double totalAcumulado;
  final VoidCallback onExportar;
  final VoidCallback onCompartilhar;

  const CardResumoVendas({
    required this.vendasDia,
    required this.vendasSemana,
    required this.vendasMes,
    required this.totalAcumulado,
    required this.onExportar,
    required this.onCompartilhar,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Resumo de Vendas',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _info('Dia', vendasDia),
                _info('Semana', vendasSemana),
                _info('Mês', vendasMes),
                _info('Total', totalAcumulado),
              ],
            ),
            ButtonBar(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exportar'),
                  onPressed: onExportar,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                  onPressed: onCompartilhar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, double valor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('R\$ ${valor.toStringAsFixed(2)}'),
      ],
    );
  }
}
