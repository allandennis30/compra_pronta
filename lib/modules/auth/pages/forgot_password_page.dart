import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/logger.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKeyRequest = GlobalKey<FormState>();
  final _formKeyReset = GlobalKey<FormState>();
  bool _codeRequested = false;
  bool _obscure = true;
  bool _loading = false;

  Future<void> _requestCode() async {
    if (!_formKeyRequest.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _authRepository.requestPasswordReset(_emailController.text.trim());
      setState(() => _codeRequested = true);
      if (mounted) {
        SnackBarUtils.showSuccess(
            context, 'Enviamos um código para seu email.');
      }
    } catch (e) {
      AppLogger.error('Erro ao solicitar código', e);
      if (mounted) {
        final raw = e.toString();
        final message = raw.startsWith('Exception: ')
            ? raw.substring('Exception: '.length)
            : raw;
        SnackBarUtils.showError(context, message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKeyReset.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _authRepository.resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        newPassword: _passwordController.text.trim(),
      );
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Senha redefinida com sucesso.');
        Get.back();
      }
    } catch (e) {
      AppLogger.error('Erro ao redefinir senha', e);
      if (mounted) {
        final raw = e.toString();
        final message = raw.startsWith('Exception: ')
            ? raw.substring('Exception: '.length)
            : raw;
        SnackBarUtils.showError(context, message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
                'Informe seu email para receber um código de redefinição.'),
            const SizedBox(height: 16),
            Form(
              key: _formKeyRequest,
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) => v != null && v.contains('@')
                    ? null
                    : 'Informe um email válido',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _requestCode,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Enviar código'),
            ),
            const Divider(height: 32),
            if (_codeRequested) ...[
              const Text('Digite o código recebido e sua nova senha.'),
              const SizedBox(height: 16),
              Form(
                key: _formKeyReset,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Código',
                        prefixIcon: Icon(Icons.verified),
                      ),
                      validator: (v) => (v != null && v.length >= 4)
                          ? null
                          : 'Código inválido',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Nova senha',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      obscureText: _obscure,
                      validator: (v) => (v != null && v.length >= 6)
                          ? null
                          : 'Mínimo 6 caracteres',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _resetPassword,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Redefinir senha'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
