import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/themes/app_theme.dart';
import 'routes/app_pages.dart';
import 'modules/auth/controllers/auth_controller.dart';
import 'modules/auth/repositories/auth_repository.dart';
import 'modules/cliente/controllers/cart_controller.dart';
import 'core/repositories/repository_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Hive.initFlutter();

  // Teste simples do GetStorage
  final testStorage = GetStorage();
  testStorage.write('test_key', 'test_value');
  final testValue = testStorage.read('test_key');
  print('🧪 [TESTE STORAGE] Valor de teste: $testValue');
  testStorage.remove('test_key');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Compra Pronta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      getPages: AppPages.pages,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
      initialBinding: BindingsBuilder(() {
        // Repositories globais usando factory
        Get.put<AuthRepository>(RepositoryFactory.createAuthRepository());

        // Controllers globais
        Get.put(AuthController());
        Get.put(CartController());
      }),
      home: _InitialRouteDecider(),
    );
  }
}

class _InitialRouteDecider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    // O controller já carrega o usuário do storage no onInit
    return Obx(() {
      if (authController.isLoading) {
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Verificando autenticação...',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Carregando dados do usuário',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }
      if (authController.isLoggedIn) {
        if (authController.isVendor) {
          // Vendedor
          Future.microtask(() => Get.offAllNamed('/vendor/dashboard'));
        } else {
          // Cliente
          Future.microtask(() => Get.offAllNamed('/cliente/produtos'));
        }
        return const SizedBox.shrink();
      }
      // Não logado
      Future.microtask(() => Get.offAllNamed('/login'));
      return const SizedBox.shrink();
    });
  }
}
