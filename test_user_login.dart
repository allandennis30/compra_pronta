import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  final storage = GetStorage();

  print('🔍 Verificando dados de autenticação...');

  // Verificar token
  final token = storage.read('auth_token');
  print('🔑 Token (auth_token): ${token != null ? 'Presente' : 'Ausente'}');
  if (token != null) {
    print('📝 Token (primeiros 20 chars): ${token.substring(0, 20)}...');
  }

  // Verificar token antigo (para compatibilidade)
  final oldToken = storage.read('token');
  print('🔑 Token (token): ${oldToken != null ? 'Presente' : 'Ausente'}');

  // Verificar dados do usuário
  final userData = storage.read('user_data');
  print('👤 User Data: ${userData != null ? 'Presente' : 'Ausente'}');
  if (userData != null) {
    print('📝 Nome: ${userData['nome']}');
    print('📧 Email: ${userData['email']}');
    print('📞 Telefone: ${userData['telefone']}');
  }

  // Verificar credenciais salvas
  final savedEmail = storage.read('saved_email');
  final savedPassword = storage.read('saved_password');
  print('💾 Email salvo: ${savedEmail ?? 'Não encontrado'}');
  print(
      '💾 Senha salva: ${savedPassword != null ? 'Presente' : 'Não encontrada'}');

  // Verificar timestamps
  final authTimestamp = storage.read('auth_timestamp');
  final credentialsTimestamp = storage.read('credentials_timestamp');
  print('⏰ Auth timestamp: ${authTimestamp != null ? 'Presente' : 'Ausente'}');
  print(
      '⏰ Credentials timestamp: ${credentialsTimestamp != null ? 'Presente' : 'Ausente'}');
}
