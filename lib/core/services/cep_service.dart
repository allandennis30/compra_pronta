import 'dart:convert';
import 'package:http/http.dart' as http;

class CepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  /// Busca dados do endereço pelo CEP
  /// Retorna um Map com os dados do endereço ou null se não encontrado
  static Future<Map<String, String>?> searchCep(String cep) async {
    try {
      // Remove caracteres não numéricos
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

      if (cleanCep.length != 8) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/$cleanCep/json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica se o CEP foi encontrado
        if (data['erro'] == true) {
          return null;
        }

        return {
          'cep': data['cep'] ?? '',
          'logradouro': data['logradouro'] ?? '',
          'bairro': data['bairro'] ?? '',
          'localidade': data['localidade'] ?? '',
          'uf': data['uf'] ?? '',
        };
      }

      return null;
    } catch (e) {
      print('Erro ao buscar CEP: $e');
      return null;
    }
  }
}
