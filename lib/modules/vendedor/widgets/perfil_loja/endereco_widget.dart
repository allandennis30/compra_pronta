import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/input_formatters.dart';
import '../../controllers/vendor_settings_controller.dart';

class EnderecoWidget extends StatefulWidget {
  final VendedorSettingsController controller;

  const EnderecoWidget({
    super.key,
    required this.controller,
  });

  @override
  State<EnderecoWidget> createState() => _EnderecoWidgetState();
}

class _EnderecoWidgetState extends State<EnderecoWidget> {
  late TextEditingController _cepController;
  late TextEditingController _ruaController;
  late TextEditingController _numeroController;
  late TextEditingController _complementoController;
  late TextEditingController _bairroController;
  late TextEditingController _cidadeController;
  late TextEditingController _estadoController;

  @override
  void initState() {
    super.initState();
    _cepController = TextEditingController(text: widget.controller.cep.value);
    _ruaController = TextEditingController(text: widget.controller.rua.value);
    _numeroController = TextEditingController(text: widget.controller.numero.value);
    _complementoController = TextEditingController(text: widget.controller.complemento.value);
    _bairroController = TextEditingController(text: widget.controller.bairro.value);
    _cidadeController = TextEditingController(text: widget.controller.cidade.value);
    _estadoController = TextEditingController(text: widget.controller.estado.value);
  }

  @override
  void dispose() {
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Atualizar controllers quando os valores mudarem
      if (_cepController.text != widget.controller.cep.value) {
        _cepController.text = widget.controller.cep.value;
      }
      if (_ruaController.text != widget.controller.rua.value) {
        _ruaController.text = widget.controller.rua.value;
      }
      if (_numeroController.text != widget.controller.numero.value) {
        _numeroController.text = widget.controller.numero.value;
      }
      if (_complementoController.text != widget.controller.complemento.value) {
        _complementoController.text = widget.controller.complemento.value;
      }
      if (_bairroController.text != widget.controller.bairro.value) {
        _bairroController.text = widget.controller.bairro.value;
      }
      if (_cidadeController.text != widget.controller.cidade.value) {
        _cidadeController.text = widget.controller.cidade.value;
      }
      if (_estadoController.text != widget.controller.estado.value) {
        _estadoController.text = widget.controller.estado.value;
      }

      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Endereço', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            
            // CEP primeiro para buscar dados automaticamente
            TextFormField(
              controller: _cepController,
              decoration: InputDecoration(
                labelText: 'CEP',
                prefixIcon: const Icon(Icons.location_on),
                border: const OutlineInputBorder(),
                hintText: '00000-000',
                suffixIcon: widget.controller.isLoadingCep.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: widget.controller.searchCep,
                            tooltip: 'Buscar endereço pelo CEP',
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: widget.controller.clearEndereco,
                            tooltip: 'Limpar endereço',
                          ),
                        ],
                      ),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [InputFormatters.cepFormatter],
              onChanged: (value) {
                widget.controller.cep.value = value;
                // Busca automaticamente quando CEP estiver completo
                if (value.replaceAll(RegExp(r'[^0-9]'), '').length == 8) {
                  widget.controller.searchCep();
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

            // Rua/Avenida
            TextFormField(
              controller: _ruaController,
              decoration: const InputDecoration(
                labelText: 'Rua/Avenida',
                prefixIcon: Icon(Icons.streetview),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [InputFormatters.addressFormatter],
              textInputAction: TextInputAction.next,
              onChanged: (value) => widget.controller.rua.value = value,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe a rua';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Número e Complemento
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _numeroController,
                    decoration: const InputDecoration(
                      labelText: 'Número',
                      prefixIcon: Icon(Icons.numbers),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [InputFormatters.onlyNumbersFormatter],
                    onChanged: (value) => widget.controller.numero.value = value,
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
                    controller: _complementoController,
                    decoration: const InputDecoration(
                      labelText: 'Complemento',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                      hintText: 'Apto, casa, etc.',
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [InputFormatters.addressFormatter],
                    onChanged: (value) => widget.controller.complemento.value = value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bairro
            TextFormField(
              controller: _bairroController,
              decoration: const InputDecoration(
                labelText: 'Bairro',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [InputFormatters.addressFormatter],
              textInputAction: TextInputAction.next,
              onChanged: (value) => widget.controller.bairro.value = value,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe o bairro';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Cidade e Estado
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cidadeController,
                    decoration: const InputDecoration(
                      labelText: 'Cidade',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [InputFormatters.onlyLettersFormatter],
                    textInputAction: TextInputAction.next,
                    enabled: !widget.controller.isCityLocked.value,
                    onChanged: (value) => widget.controller.cidade.value = value,
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
                    controller: _estadoController,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      prefixIcon: Icon(Icons.flag),
                      border: OutlineInputBorder(),
                      hintText: 'SP',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [InputFormatters.onlyLettersFormatter],
                    textInputAction: TextInputAction.done,
                    enabled: !widget.controller.isStateLocked.value,
                    onChanged: (value) => widget.controller.estado.value = value,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'UF';
                      }
                      if (v.length != 2) {
                        return 'UF inválida';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
    });
  }
}