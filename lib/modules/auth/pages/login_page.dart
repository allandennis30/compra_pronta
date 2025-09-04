import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  final RxBool _obscurePassword = true.obs;
  final RxBool _saveCredentials = true.obs;

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
              // Checkbox para salvar credenciais
              Obx(() => Row(
                    children: [
                      Checkbox(
                        value: _saveCredentials.value,
                        onChanged: (value) =>
                            _saveCredentials.value = value ?? true,
                      ),
                      const Expanded(
                        child: Text(
                          'Salvar credenciais para login automático',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.to(() => const ForgotPasswordPage()),
                  child: const Text('Esqueceu a senha?'),
                ),
              ),
              const SizedBox(height: 8),
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
                                saveCredentials: _saveCredentials.value,
                              );
                              if (_authController.isLoggedIn) {
                                if (_authController.isVendor) {
                                  Get.offAllNamed('/vendor/dashboard');
                                } else {
                                  Get.offAllNamed('/cliente');
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
