import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/themes/app_theme.dart';
import 'routes/app_pages.dart';
import 'modules/auth/controllers/auth_controller.dart';
import 'modules/auth/repositories/auth_repository.dart';
import 'modules/cliente/controllers/cart_controller.dart';
import 'core/repositories/repository_factory.dart';
import 'core/controllers/update_controller.dart';
import 'core/services/app_update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  print('✅ [MAIN] Firebase inicializado');
  
  // Bloquear rotação do app - apenas portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
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
      themeMode: ThemeMode.system, // Reage automaticamente ao tema do sistema
      getPages: AppPages.pages,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
      initialBinding: BindingsBuilder(() {
        // Repositories globais usando factory
        Get.put<AuthRepository>(RepositoryFactory.createAuthRepository());

        // Services globais
        Get.put(AppUpdateService());

        // Controllers globais
        Get.put(AuthController());
        Get.put(CartController());
        Get.put(UpdateController());
      }),
      home: _InitialRouteDecider(),
    );
  }
}

class _InitialRouteDecider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final UpdateController updateController = Get.find<UpdateController>();
    
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
      
      // Verificar atualizações após autenticação
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateController.checkForUpdates(showLoading: false);
      });
      
      if (authController.isLoggedIn) {
        if (authController.isVendor) {
          // Vendedor
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed('/vendor/dashboard');
          });
        } else {
          // Cliente
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed('/cliente');
          });
        }
        return const SizedBox.shrink();
      }
      // Não logado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/login');
      });
      return const SizedBox.shrink();
    });
  }
}
