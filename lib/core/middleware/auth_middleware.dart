import 'package:get/get.dart';
import '../../modules/auth/controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final authController = Get.find<AuthController>();

    // Aguardar a inicialização do controller
    if (authController.isLoading) {
      return null; // Aguardar
    }

    // Se o usuário está logado, permitir acesso
    if (authController.isLoggedIn) {
      return null;
    }

    // Se não está logado, redirecionar para login
    return GetNavConfig.fromRoute('/login');
  }
}

class VendorAuthMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final authController = Get.find<AuthController>();

    // Aguardar a inicialização do controller
    if (authController.isLoading) {
      return null; // Aguardar
    }

    // Se o usuário está logado e é vendedor, permitir acesso
    if (authController.isLoggedIn && authController.isVendor) {
      return null;
    }

    // Se não está logado, redirecionar para login
    if (!authController.isLoggedIn) {
      return GetNavConfig.fromRoute('/login');
    }

    // Se está logado mas não é vendedor, redirecionar para área do cliente
    return GetNavConfig.fromRoute('/cliente/produtos');
  }
}

class ClientAuthMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final authController = Get.find<AuthController>();

    // Aguardar a inicialização do controller
    if (authController.isLoading) {
      return null; // Aguardar
    }

    // Se o usuário está logado e é cliente, permitir acesso
    if (authController.isLoggedIn && authController.isClient) {
      return null;
    }

    // Se não está logado, redirecionar para login
    if (!authController.isLoggedIn) {
      return GetNavConfig.fromRoute('/login');
    }

    // Se está logado mas não é cliente, redirecionar para área do vendedor
    return GetNavConfig.fromRoute('/vendor/dashboard');
  }
}
