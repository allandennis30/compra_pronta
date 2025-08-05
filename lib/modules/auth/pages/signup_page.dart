import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/models/user_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isVendor = false;

  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? 'E-mail inválido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirme a senha'),
                  obscureText: true,
                  validator: (v) => v != _passwordController.text ? 'Senhas não conferem' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Informe o telefone' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(labelText: 'Rua'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe a rua' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(labelText: 'Número'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe o número' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _complementController,
                  decoration: const InputDecoration(labelText: 'Complemento (opcional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _neighborhoodController,
                  decoration: const InputDecoration(labelText: 'Bairro'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe o bairro' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'Cidade'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe a cidade' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe o estado' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _zipController,
                  decoration: const InputDecoration(labelText: 'CEP'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe o CEP' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _isVendor,
                      onChanged: (v) => setState(() => _isVendor = v ?? false),
                    ),
                    const Text('Quero cadastrar como vendedor'),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _authController.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  // Simular localização GPS
                                  double latitude = -23.550520;
                                  double longitude = -46.633308;
                                  AddressModel address = AddressModel(
                                    street: _streetController.text.trim(),
                                    number: _numberController.text.trim(),
                                    complement: _complementController.text.trim().isEmpty ? null : _complementController.text.trim(),
                                    neighborhood: _neighborhoodController.text.trim(),
                                    city: _cityController.text.trim(),
                                    state: _stateController.text.trim(),
                                    zipCode: _zipController.text.trim(),
                                  );
                                  bool ok = await _authController.signup(
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                    phone: _phoneController.text.trim(),
                                    address: address,
                                    latitude: latitude,
                                    longitude: longitude,
                                    context: context,
                                    istore: _isVendor,
                                  );
                                  if (ok) {
                                    if (_isVendor) {
                                      Get.offAllNamed('/vendor/dashboard');
                                    } else {
                                      Get.offAllNamed('/cliente/produtos');
                                    }
                                  }
                                }
                              },
                        child: _authController.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Cadastrar'),
                      ),
                    )),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Já tem conta? Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}