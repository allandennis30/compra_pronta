import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/cep_service.dart';
import '../../../core/utils/input_formatters.dart';

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
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoadingCep = false;
  bool _isCityLocked = false;
  bool _isStateLocked = false;

  final AuthController _authController = Get.find();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  /// Busca dados do endereço pelo CEP
  Future<void> _searchCep() async {
    final cep = _zipController.text;
    if (cep.length < 8) return;

    setState(() {
      _isLoadingCep = true;
    });

    try {
      final cepData = await CepService.searchCep(cep);

      if (cepData != null) {
        if (mounted) {
          setState(() {
            _streetController.text = cepData['logradouro'] ?? '';
            _neighborhoodController.text = cepData['bairro'] ?? '';
            _cityController.text = cepData['localidade'] ?? '';
            _stateController.text = cepData['uf'] ?? '';

            // Bloqueia os campos cidade e UF quando preenchidos automaticamente
            _isCityLocked = cepData['localidade']?.isNotEmpty == true;
            _isStateLocked = cepData['uf']?.isNotEmpty == true;
          });

          // Foca no campo número após preencher os dados
          FocusScope.of(context).requestFocus(FocusNode());
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              FocusScope.of(context).requestFocus(FocusNode());
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            // Desbloqueia os campos se o CEP não for encontrado
            _isCityLocked = false;
            _isStateLocked = false;
          });

          Get.snackbar(
            'CEP não encontrado',
            'Verifique o CEP informado',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Desbloqueia os campos em caso de erro
          _isCityLocked = false;
          _isStateLocked = false;
        });

        Get.snackbar(
          'Erro',
          'Erro ao buscar CEP. Tente novamente.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCep = false;
        });
      }
    }
  }

  /// Desbloqueia os campos cidade e UF para edição manual
  void _unlockCityAndState() {
    setState(() {
      _isCityLocked = false;
      _isStateLocked = false;
    });
  }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção: Dados Pessoais
                _buildSectionTitle('Dados Pessoais'),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [InputFormatters.onlyLettersFormatter],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o nome';
                    }
                    if (v.trim().length < 2) {
                      return 'Nome deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o e-mail';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v.trim())) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Informe a senha';
                    }
                    if (v.length < 6) {
                      return 'Senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    hintText: '(11) 99999-9999',
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [InputFormatters.phoneFormatter],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o telefone';
                    }
                    if (v.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
                      return 'Telefone inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Seção: Endereço
                _buildSectionTitle('Endereço'),
                const SizedBox(height: 16),

                // CEP primeiro para buscar dados automaticamente
                TextFormField(
                  controller: _zipController,
                  decoration: InputDecoration(
                    labelText: 'CEP',
                    prefixIcon: const Icon(Icons.location_on),
                    border: const OutlineInputBorder(),
                    hintText: '00000-000',
                    suffixIcon: _isLoadingCep
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _searchCep,
                            tooltip: 'Buscar endereço pelo CEP',
                          ),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [InputFormatters.cepFormatter],
                  onChanged: (value) {
                    // Busca automaticamente quando CEP estiver completo
                    if (value.replaceAll(RegExp(r'[^0-9]'), '').length == 8) {
                      _searchCep();
                    }
                  },
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o CEP';
                    }
                    if (v.replaceAll(RegExp(r'[^0-9]'), '').length != 8) {
                      return 'CEP inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Rua/Avenida',
                    prefixIcon: Icon(Icons.streetview),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [InputFormatters.addressFormatter],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe a rua';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _numberController,
                        decoration: const InputDecoration(
                          labelText: 'Número',
                          prefixIcon: Icon(Icons.home),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          InputFormatters.alphanumericFormatter
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe o número';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _complementController,
                        decoration: const InputDecoration(
                          labelText: 'Complemento (opcional)',
                          prefixIcon: Icon(Icons.info),
                          border: OutlineInputBorder(),
                          hintText: 'Apto, sala, etc.',
                        ),
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [
                          InputFormatters.alphanumericFormatter
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _neighborhoodController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro',
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [InputFormatters.onlyLettersFormatter],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o bairro';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: 'Cidade',
                          prefixIcon: const Icon(Icons.location_city),
                          border: const OutlineInputBorder(),
                          suffixIcon: _isCityLocked
                              ? IconButton(
                                  icon: const Icon(Icons.lock, size: 18),
                                  onPressed: _unlockCityAndState,
                                  tooltip: 'Clique para editar manualmente',
                                  color: Colors.blue,
                                )
                              : null,
                        ),
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [InputFormatters.onlyLettersFormatter],
                        textInputAction: TextInputAction.next,
                        readOnly: _isCityLocked,
                        style: TextStyle(
                          color: _isCityLocked ? Colors.grey[600] : null,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe a cidade';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _stateController,
                        decoration: InputDecoration(
                          labelText: 'UF',
                          prefixIcon: const Icon(Icons.map),
                          border: const OutlineInputBorder(),
                          hintText: 'SP',
                          suffixIcon: _isStateLocked
                              ? IconButton(
                                  icon: const Icon(Icons.lock, size: 18),
                                  onPressed: _unlockCityAndState,
                                  tooltip: 'Clique para editar manualmente',
                                  color: Colors.blue,
                                )
                              : null,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [InputFormatters.onlyLettersFormatter],
                        textInputAction: TextInputAction.done,
                        readOnly: _isStateLocked,
                        style: TextStyle(
                          color: _isStateLocked ? Colors.grey[600] : null,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe o estado';
                          }
                          if (v.trim().length != 2) {
                            return 'UF deve ter 2 letras';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Informação sobre campos bloqueados
                if (_isCityLocked || _isStateLocked)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cidade e UF foram preenchidos automaticamente pelo CEP. Clique no ícone de cadeado para editar manualmente.',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Botão de cadastro
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _authController.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  // Simular localização GPS
                                  double latitude = -23.550520;
                                  double longitude = -46.633308;
                                  AddressModel address = AddressModel(
                                    street: _streetController.text.trim(),
                                    number: _numberController.text.trim(),
                                    complement: _complementController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : _complementController.text.trim(),
                                    neighborhood:
                                        _neighborhoodController.text.trim(),
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
                                    istore: false,
                                  );
                                  if (ok) {
                                    Get.offAllNamed('/cliente/produtos');
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _authController.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Cadastrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )),
                const SizedBox(height: 16),

                // Link para login
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Já tem conta? Entrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
}
