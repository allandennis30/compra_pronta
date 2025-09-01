import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  final storage = GetStorage();

  print('🔍 [DEBUG] Verificando estado do storage para checkout...');

  // Verificar token
  final token = storage.read('auth_token');
  print('🔑 Token (auth_token): ${token != null ? 'Presente' : 'Ausente'}');
  if (token != null) {
    print('📝 Token (primeiros 20 chars): ${token.substring(0, 20)}...');
  }

  // Verificar user_id
  final userId = storage.read('user_id');
  print('🆔 User ID: ${userId ?? 'Não encontrado'}');

  // Verificar dados do usuário
  final userData = storage.read('user');
  print('👤 User Data: ${userData != null ? 'Presente' : 'Ausente'}');
  if (userData != null) {
    print('📝 Nome: ${userData['name']}');
    print('📧 Email: ${userData['email']}');
    print('📞 Phone: ${userData['phone']}');
  }

  // Verificar carrinho
  final cartData = storage.read('cart');
  print('🛒 Cart Data: ${cartData != null ? 'Presente' : 'Ausente'}');
  if (cartData != null && cartData is List) {
    print('📦 Itens no carrinho: ${cartData.length}');
  }

  // Verificar pedidos
  final ordersData = storage.read('orders');
  print('📋 Orders Data: ${ordersData != null ? 'Presente' : 'Ausente'}');
  if (ordersData != null && ordersData is List) {
    print('📋 Pedidos salvos: ${ordersData.length}');
  }

  print('\n✅ [DEBUG] Verificação concluída!');
}
