import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  final storage = GetStorage();

  // Verificar se o token existe
  final token = storage.read('token');
  final userData = storage.read('user_data');

  print('🔑 Token: ${token != null ? 'Presente' : 'Ausente'}');
  if (token != null) {
    print('📝 Token (primeiros 20 chars): ${token.substring(0, 20)}...');
  }

  print('👤 User Data: ${userData != null ? 'Presente' : 'Ausente'}');
  if (userData != null) {
    print('📝 Nome: ${userData['nome']}');
    print('📧 Email: ${userData['email']}');
    print('📞 Telefone: ${userData['telefone']}');
  }
}
