import 'dart:io';

void main() async {
  
  // Teste 1: Verificar se o backend local está rodando
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://192.168.3.43:3000/health'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
    } else {
    }
    client.close();
  } catch (e) {

    }
  
  // Teste 2: Verificar se o Render está acessível
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('https://mercax-backend.onrender.com/health'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
    } else {
    }
    client.close();
  } catch (e) {
  }
  
  // Teste 3: Simular lógica de fallback
  
  
  
}

Future<String> getBaseUrl() async {
  // Simula a lógica do AppConstants
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);
    
    final request = await client.getUrl(Uri.parse('https://mercax-backend.onrender.com/health'));
    final response = await request.close();
    client.close();
    
    if (response.statusCode == 200) {
      return 'https://mercax-backend.onrender.com';
    }
  } catch (e) {
  }
  
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    
    final request = await client.getUrl(Uri.parse('http://192.168.3.43:3000/health'));
    final response = await request.close();
    client.close();
    
    if (response.statusCode == 200) {
      return 'http://192.168.3.43:3000';
    }
  } catch (e) {
  }
  
  return 'https://mercax-backend.onrender.com';
}

Future<String> getLoginEndpoint(String baseUrl) async {
  return '$baseUrl/auth/login';
}