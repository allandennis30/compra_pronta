import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  final storage = GetStorage();

  print('🔍 [DEBUG] Verificando user_id no storage...');

  // Verificar user_id
  final userId = storage.read('user_id');
  print('🆔 User ID: ${userId ?? 'Não encontrado'}');

  // Verificar token
  final token = storage.read('auth_token');
  print('🔑 Token: ${token != null ? 'Presente' : 'Ausente'}');

  // Verificar dados do usuário
  final userData = storage.read('user');
  print('👤 User Data: ${userData != null ? 'Presente' : 'Ausente'}');
  if (userData != null) {
    print('📝 Nome: ${userData['name']}');
    print('📧 Email: ${userData['email']}');
    print('🆔 ID do user data: ${userData['id']}');
  }

  // Verificar se o user_id está sendo salvo corretamente
  if (userId == null && userData != null && userData['id'] != null) {
    print('⚠️ [DEBUG] User ID não encontrado, mas existe no user data!');
    print('💡 [DEBUG] Tentando salvar user_id manualmente...');

    await storage.write('user_id', userData['id']);
    print('✅ [DEBUG] User ID salvo manualmente: ${userData['id']}');
  }

  print('\n✅ [DEBUG] Verificação concluída!');
}
