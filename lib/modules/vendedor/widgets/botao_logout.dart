import 'package:flutter/material.dart';

class BotaoLogout extends StatelessWidget {
  final VoidCallback onLogout;
  final Function(String) onAlterarSenha;

  const BotaoLogout({
    required this.onLogout,
    required this.onAlterarSenha,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Sair da Conta'),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Confirmação'),
                content: const Text('Deseja realmente sair da conta?'),
                actions: [
                  TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () => Navigator.pop(context, false)),
                  TextButton(
                      child: const Text('Sair'),
                      onPressed: () => Navigator.pop(context, true)),
                ],
              ),
            );
            if (confirm == true) onLogout();
          },
        ),
        TextButton(
          child: const Text('Alterar Senha'),
          onPressed: () async {
            final novaSenha = await showDialog<String>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Alterar Senha'),
                content: const TextField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Nova Senha')),
                actions: [
                  TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () => Navigator.pop(context)),
                  TextButton(
                      child: const Text('Salvar'),
                      onPressed: () => Navigator.pop(context, 'novaSenha')),
                ],
              ),
            );
            if (novaSenha != null && novaSenha.isNotEmpty)
              onAlterarSenha(novaSenha);
          },
        ),
      ],
    );
  }
}
