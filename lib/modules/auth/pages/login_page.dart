import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  final RxBool _obscurePassword = true.obs;

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              Obx(() => TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword.value
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => _obscurePassword.toggle(),
                      ),
                    ),
                    obscureText: _obscurePassword.value,
                  )),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authController.isLoading
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();
                              await _authController.login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                context,
                              );
                              if (_authController.isLoggedIn) {
                                if (_authController.isVendor) {
                                  Get.offAllNamed('/vendor/dashboard');
                                } else {
                                  Get.offAllNamed('/cliente/produtos');
                                }
                              }
                            },
                      child: _authController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Entrar'),
                    ),
                  )),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.toNamed('/signup'),
                child: const Text('Não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
