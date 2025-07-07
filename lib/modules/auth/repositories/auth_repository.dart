import 'package:get_storage/get_storage.dart';
import '../../../core/models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required AddressModel address,
    required double latitude,
    required double longitude,
    bool istore = false,
  });
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
  Future<void> logout();
  Future<void> updateUser(UserModel user);
}

class AuthRepositoryImpl implements AuthRepository {
  final GetStorage _storage = GetStorage();

  @override
  Future<UserModel?> login(String email, String password) async {
    // Simular delay de rede
    await Future.delayed(Duration(seconds: 1));
    
    // Verificar credenciais mock
    UserModel? user;
    
    if (email == 'testecliente@teste.com' && password == 'Senha@123') {
      user = UserModel.fromJson(AppConstants.mockCliente);
    } else if (email == 'testevendedor@teste.com' && password == 'Venda@123') {
      user = UserModel.fromJson(AppConstants.mockVendedor);
    }
    
    if (user != null) {
      await saveUser(user);
    }
    
    return user;
  }

  @override
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required AddressModel address,
    required double latitude,
    required double longitude,
    bool istore = false,
  }) async {
    // Simular delay de rede
    await Future.delayed(Duration(seconds: 1));
    
    // Criar novo usuário
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      address: address,
      latitude: latitude,
      longitude: longitude,
      istore: istore,
    );
    
    await saveUser(user);
    return user;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = _storage.read(AppConstants.userKey);
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar usuário do storage', e);
    }
    return null;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _storage.write(AppConstants.userKey, user.toJson());
    } catch (e) {
      AppLogger.error('Erro ao salvar usuário', e);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _storage.remove(AppConstants.userKey);
      await _storage.remove(AppConstants.cartKey);
    } catch (e) {
      AppLogger.error('Erro ao fazer logout', e);
      rethrow;
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await saveUser(user);
  }
} 