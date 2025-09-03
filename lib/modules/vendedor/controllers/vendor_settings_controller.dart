// ignore_for_file: file_names
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/horario_funcionamento.dart';
import '../../../repositories/store_settings_repository.dart';
import '../../../core/services/cep_service.dart';

class VendedorSettingsController extends GetxController {
  // Informações da loja
  var nomeLoja = ''.obs;
  var cnpjCpf = ''.obs;
  var descricao = ''.obs;
  var endereco = ''.obs;
  var telefone = ''.obs;
  var logoUrl = ''.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;

  // Campos de endereço separados
  var rua = ''.obs;
  var numero = ''.obs;
  var complemento = ''.obs;
  var bairro = ''.obs;
  var cidade = ''.obs;
  var estado = ''.obs;
  var cep = ''.obs;

  // Controle da busca de CEP
  var isLoadingCep = false.obs;
  var isCityLocked = false.obs;
  var isStateLocked = false.obs;

  // Preferências de operação
  var horarioInicio = const TimeOfDay(hour: 8, minute: 0).obs;
  var horarioFim = const TimeOfDay(hour: 18, minute: 0).obs;
  var aceitaForaHorario = false.obs;
  var tempoPreparo = 30.obs;
  var mensagemBoasVindas = ''.obs;

  // Horário de funcionamento por dia da semana
  final horariosFuncionamento = <HorarioFuncionamento>[].obs;

  // Política de entrega
  var taxaEntrega = 0.0.obs;
  var raioEntrega = 5.0.obs;
  var limiteEntregaGratis = 100.0.obs;
  var tempoEntregaMin = 30.obs;
  var tempoEntregaMax = 60.obs;
  var pedidoMinimo = 0.0.obs;

  // Configurações adicionais
  var categoriaLoja = 'Supermercado'.obs;
  var aceitaCartao = true.obs;
  var aceitaDinheiro = true.obs;
  var aceitaPix = true.obs;
  var ativo = true.obs;

  final StoreSettingsRepository _storeSettingsRepository =
      StoreSettingsRepository();
  bool get isVendedor => Get.find<AuthController>().isVendor;

  Future<void> carregarDadosLoja() async {
    try {
      print('🔍 [VENDOR_SETTINGS] Iniciando carregamento de dados...');
      final settings = await _storeSettingsRepository.getStoreSettings();
      print('🔍 [VENDOR_SETTINGS] Dados recebidos: $settings');
      
      // Debug: mostrar todos os campos disponíveis
      if (settings != null) {
        print('🔍 [VENDOR_SETTINGS] Campos disponíveis no backend:');
        settings.forEach((key, value) {
          print('   $key: $value (${value.runtimeType})');
        });
      }

      if (settings != null) {
        print('🔍 [VENDOR_SETTINGS] Atribuindo dados aos observables...');

        // Carregar dados da loja
        nomeLoja.value = settings['nome_empresa']?? '';
        cnpjCpf.value = settings['cnpj']?? '';
        descricao.value = settings['descricao'] ?? '';
        telefone.value = settings['telefone'] ?? '';
        logoUrl.value = settings['logoUrl'] ?? '';
        latitude.value = (settings['latitude'] ?? 0.0).toDouble();
        longitude.value = (settings['longitude'] ?? 0.0).toDouble();

        // Carregar endereço separadamente
        final enderecoData = settings['endereco'];
        if (enderecoData != null) {
          if (enderecoData is Map<String, dynamic>) {
            // Endereço já está em formato de objeto
            rua.value = enderecoData['rua'] ?? enderecoData['street'] ?? '';
            numero.value = enderecoData['numero']?.toString() ?? enderecoData['number']?.toString() ?? '';
            complemento.value = enderecoData['complemento'] ?? enderecoData['complement'] ?? '';
            bairro.value = enderecoData['bairro'] ?? enderecoData['neighborhood'] ?? '';
            cidade.value = enderecoData['cidade'] ?? enderecoData['city'] ?? '';
            estado.value = enderecoData['estado'] ?? enderecoData['state'] ?? '';
            cep.value = enderecoData['cep'] ?? enderecoData['zipCode'] ?? '';
            
            // Se CEP estiver vazio, tentar buscar de outros campos
            if (cep.value.isEmpty) {
              // Verificar se há CEP em outros campos do endereço
              cep.value = enderecoData['cep'] ?? enderecoData['zipCode'] ?? enderecoData['postalCode'] ?? '';
            }
          } else {
            // Endereço está como string, tentar converter
            final enderecoStr = enderecoData.toString();
            endereco.value = enderecoStr;
            _parseEnderecoString(enderecoStr);
          }
        }


        // Carregar preferências de operação
        if (settings['horarioInicio'] != null) {
          final horarioInicioStr = settings['horarioInicio'];
          final parts = horarioInicioStr.split(':');
          if (parts.length == 2) {
            horarioInicio.value = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
        }

        if (settings['horarioFim'] != null) {
          final horarioFimStr = settings['horarioFim'];
          final parts = horarioFimStr.split(':');
          if (parts.length == 2) {
            horarioFim.value = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
        }

        aceitaForaHorario.value = settings['aceitaForaHorario'] ?? false;
        tempoPreparo.value = settings['tempoPreparo'] ?? 30;
        mensagemBoasVindas.value = settings['mensagemBoasVindas'] ?? '';


        // Carregar horários de funcionamento
        if (settings['horariosFuncionamento'] != null) {
          final horariosData = settings['horariosFuncionamento'] as List;
          horariosFuncionamento.clear();
          for (final horarioData in horariosData) {
            horariosFuncionamento
                .add(HorarioFuncionamento.fromJson(horarioData));
          }
          print(
              '🔍 [VENDOR_SETTINGS] Horários de funcionamento carregados: ${horariosFuncionamento.length} dias');
        }

        // Carregar política de entrega
        taxaEntrega.value = (settings['taxa_entrega'] ?? settings['taxaEntrega'] ?? 0.0).toDouble();
        raioEntrega.value = (settings['raioEntrega'] ?? 5.0).toDouble();
        limiteEntregaGratis.value = (settings['limiteEntregaGratis'] ?? 100.0).toDouble();
        tempoEntregaMin.value = (settings['tempo_entrega_min'] ?? settings['tempoEntregaMin'] ?? 30).toInt();
        tempoEntregaMax.value = (settings['tempo_entrega_max'] ?? settings['tempoEntregaMax'] ?? 60).toInt();
        pedidoMinimo.value = (settings['pedido_minimo'] ?? settings['pedidoMinimo'] ?? 0.0).toDouble();

        // Carregar configurações adicionais
        categoriaLoja.value = settings['categoria_loja'] ?? settings['categoriaLoja'] ?? 'Supermercado';
        aceitaCartao.value = settings['aceita_cartao'] ?? settings['aceitaCartao'] ?? true;
        aceitaDinheiro.value = settings['aceita_dinheiro'] ?? settings['aceitaDinheiro'] ?? true;
        aceitaPix.value = settings['aceita_pix'] ?? settings['aceitaPix'] ?? true;
        ativo.value = settings['ativo'] ?? true;

      
      }

      // Inicializar horários de funcionamento se estiver vazio
      if (horariosFuncionamento.isEmpty) {
        _inicializarHorariosFuncionamento();
      }
    } catch (e) {
      print('Erro ao carregar dados da loja: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar as configurações da loja',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Inicializar horários de funcionamento padrão
      if (horariosFuncionamento.isEmpty) {
        _inicializarHorariosFuncionamento();
      }
    }
  }

  /// Limpa os campos de endereço
  void clearEndereco() {
    rua.value = '';
    numero.value = '';
    complemento.value = '';
    bairro.value = '';
    cidade.value = '';
    estado.value = '';
    cep.value = '';
    isCityLocked.value = false;
    isStateLocked.value = false;
  }

  /// Busca dados do endereço pelo CEP
  Future<void> searchCep() async {
    final cepValue = cep.value;
    if (cepValue.length < 8) return;

    isLoadingCep.value = true;

    try {
      final cepData = await CepService.searchCep(cepValue);

      if (cepData != null) {
        rua.value = cepData['logradouro'] ?? '';
        bairro.value = cepData['bairro'] ?? '';
        cidade.value = cepData['localidade'] ?? '';
        estado.value = cepData['uf'] ?? '';

        // Bloqueia os campos cidade e UF quando preenchidos automaticamente
        isCityLocked.value = cepData['localidade']?.isNotEmpty == true;
        isStateLocked.value = cepData['uf']?.isNotEmpty == true;

        Get.snackbar(
          'CEP encontrado',
          'Endereço preenchido automaticamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Desbloqueia os campos se o CEP não for encontrado
        isCityLocked.value = false;
        isStateLocked.value = false;

        Get.snackbar(
          'CEP não encontrado',
          'Verifique o CEP informado',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Desbloqueia os campos em caso de erro
      isCityLocked.value = false;
      isStateLocked.value = false;

      Get.snackbar(
        'Erro',
        'Erro ao buscar CEP. Tente novamente.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingCep.value = false;
    }
  }

  void _parseEnderecoString(String enderecoStr) {
    try {
      // Tentar fazer parse de string no formato "Rua, Número, Bairro, Cidade, Estado, CEP"
      final parts = enderecoStr.split(',').map((e) => e.trim()).toList();
      
      if (parts.length >= 6) {
        // Padrão: "Rua, Número, Bairro, Cidade, Estado, CEP"
        rua.value = parts[0];
        numero.value = parts[1];
        bairro.value = parts[2];
        cidade.value = parts[3];
        estado.value = parts[4];
        cep.value = parts[5];
        if (parts.length > 6) {
          complemento.value = parts[6];
        }
      } else if (parts.length >= 4) {
        // Padrão alternativo: "Rua, Bairro, Cidade, Estado"
        rua.value = parts[0];
        bairro.value = parts[1];
        cidade.value = parts[2];
        estado.value = parts[3];
        if (parts.length > 4) {
          cep.value = parts[4];
        }
      }
    } catch (e) {
      print('Erro ao fazer parse do endereço: $e');
    }
  }

  void _inicializarHorariosFuncionamento() {
    // Inicializa todos os dias da semana com o mesmo horário padrão
    final horaInicioPadrao = TimeOfDay(hour: 8, minute: 0);
    final horaFimPadrao = TimeOfDay(hour: 18, minute: 0);

    horariosFuncionamento.clear();

    // Segunda a sexta: horário comercial
    for (int i = 0; i < 5; i++) {
      horariosFuncionamento.add(HorarioFuncionamento(
        horarioInicio: horaInicioPadrao,
        horarioFim: horaFimPadrao,
        ativo: true,
      ));
    }

    // Sábado: meio período
    horariosFuncionamento.add(HorarioFuncionamento(
      horarioInicio: horaInicioPadrao,
      horarioFim: TimeOfDay(hour: 13, minute: 0),
      ativo: true,
    ));

    // Domingo: fechado
    horariosFuncionamento.add(HorarioFuncionamento(
      horarioInicio: horaInicioPadrao,
      horarioFim: horaFimPadrao,
      ativo: false,
    ));
  }

  Future<void> selecionarHorarioPorDia(int diaSemana) async {
    if (diaSemana < 0 || diaSemana >= horariosFuncionamento.length) return;

    final horario = horariosFuncionamento[diaSemana];
    if (!horario.ativo) return;

    // Selecionar horário inicial
    final novoHorarioInicio = await _mostrarSeletorHorario(
      Get.context!,
      horario.horarioInicio,
      'Selecione o horário de abertura',
    );

    if (novoHorarioInicio == null) return;

    // Selecionar horário final
    final novoHorarioFim = await _mostrarSeletorHorario(
      Get.context!,
      horario.horarioFim,
      'Selecione o horário de fechamento',
    );

    if (novoHorarioFim == null) return;

    // Atualizar horário
    horariosFuncionamento[diaSemana] = horario.copyWith(
      horarioInicio: novoHorarioInicio,
      horarioFim: novoHorarioFim,
    );
  }

  Future<TimeOfDay?> _mostrarSeletorHorario(
    BuildContext context,
    TimeOfDay horarioInicial,
    String titulo,
  ) async {
    return showTimePicker(
      context: context,
      initialTime: horarioInicial,
      helpText: titulo,
    );
  }

  void toggleDiaAtivo(int diaSemana) {
    if (diaSemana < 0 || diaSemana >= horariosFuncionamento.length) return;

    final horario = horariosFuncionamento[diaSemana];
    horariosFuncionamento[diaSemana] = horario.copyWith(ativo: !horario.ativo);
  }

  void copiarHorarioParaTodosDias() {
    // Obtem o horário da segunda-feira (índice 0)
    if (horariosFuncionamento.isEmpty) return;

    final horarioReferencia = horariosFuncionamento[0];

    // Aplica para os outros dias (exceto domingo)
    for (int i = 1; i < horariosFuncionamento.length - 1; i++) {
      final horarioAtual = horariosFuncionamento[i];
      horariosFuncionamento[i] = horarioAtual.copyWith(
        horarioInicio: horarioReferencia.horarioInicio,
        horarioFim: horarioReferencia.horarioFim,
      );
    }

    Get.snackbar(
      'Horários atualizados',
      'O mesmo horário foi aplicado para todos os dias úteis',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> salvarDadosLoja() async {
    try {
      // Preparar dados para enviar ao backend
      final enderecoData = {
        'rua': rua.value,
        'numero': numero.value,
        'complemento': complemento.value,
        'bairro': bairro.value,
        'cidade': cidade.value,
        'estado': estado.value,
        'cep': cep.value,
      };

      final settingsData = {
        'nome_empresa': nomeLoja.value,
        'cnpj': cnpjCpf.value,
        'descricao': descricao.value,
        'endereco': enderecoData,
        'telefone': telefone.value,
        'logoUrl': logoUrl.value,
        'latitude': latitude.value,
        'longitude': longitude.value,
        'horarioInicio':
            '${horarioInicio.value.hour.toString().padLeft(2, '0')}:${horarioInicio.value.minute.toString().padLeft(2, '0')}',
        'horarioFim':
            '${horarioFim.value.hour.toString().padLeft(2, '0')}:${horarioFim.value.minute.toString().padLeft(2, '0')}',
        'aceitaForaHorario': aceitaForaHorario.value,
        'tempoPreparo': tempoPreparo.value,
        'mensagemBoasVindas': mensagemBoasVindas.value,
        'horariosFuncionamento':
            horariosFuncionamento.map((h) => h.toJson()).toList(),
        'taxaEntrega': taxaEntrega.value,
        'raioEntrega': raioEntrega.value,
        'limiteEntregaGratis': limiteEntregaGratis.value,
        'tempoEntregaMin': tempoEntregaMin.value,
        'tempoEntregaMax': tempoEntregaMax.value,
        'pedidoMinimo': pedidoMinimo.value,
        'categoriaLoja': categoriaLoja.value,
        'aceitaCartao': aceitaCartao.value,
        'aceitaDinheiro': aceitaDinheiro.value,
        'aceitaPix': aceitaPix.value,
        'ativo': ativo.value,
      };

      await _storeSettingsRepository.saveStoreSettings(settingsData);

      Get.snackbar(
        'Sucesso',
        'Configurações da loja salvas com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Erro ao salvar dados da loja: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível salvar as configurações da loja',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> atualizarLocalizacao() async {
    // TODO: Obter localização via GPS e atualizar latitude/longitude
  }



  Future<void> alterarSenha(String novaSenha) async {
    // TODO: Chamar backend para alterar senha
  }

  Future<void> logout() async {
    // TODO: Limpar cache, controllers, sessão e redirecionar para login
    await Get.find<AuthController>().logout();
  }





  Future<void> selecionarHorario() async {
    // TODO: Abrir diálogo para selecionar horário de funcionamento
  }

  @override
  void onInit() {
    super.onInit();
    carregarDadosLoja();
  }
}
