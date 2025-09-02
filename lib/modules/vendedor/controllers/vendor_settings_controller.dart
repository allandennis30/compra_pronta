// ignore_for_file: file_names
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/horario_funcionamento.dart';
import '../../../repositories/store_settings_repository.dart';

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

  // Estado extra
  var lojaOffline = false.obs;

  // Resumo de vendas
  var vendasDia = 0.0.obs;
  var vendasSemana = 0.0.obs;
  var vendasMes = 0.0.obs;
  var totalAcumulado = 0.0.obs;

  final StoreSettingsRepository _storeSettingsRepository =
      StoreSettingsRepository();
  bool get isVendedor => Get.find<AuthController>().isVendor;

  Future<void> carregarDadosLoja() async {
    try {
      print('🔍 [VENDOR_SETTINGS] Iniciando carregamento de dados...');
      final settings = await _storeSettingsRepository.getStoreSettings();
      print('🔍 [VENDOR_SETTINGS] Dados recebidos: $settings');

      if (settings != null) {
        print('🔍 [VENDOR_SETTINGS] Atribuindo dados aos observables...');

        // Carregar dados da loja
        nomeLoja.value = settings['nomeLoja'] ?? '';
        cnpjCpf.value = settings['cnpjCpf'] ?? '';
        descricao.value = settings['descricao'] ?? '';
        endereco.value = settings['endereco']?.toString() ?? '';
        telefone.value = settings['telefone'] ?? '';
        logoUrl.value = settings['logoUrl'] ?? '';
        latitude.value = (settings['latitude'] ?? 0.0).toDouble();
        longitude.value = (settings['longitude'] ?? 0.0).toDouble();

        print('🔍 [VENDOR_SETTINGS] Dados básicos atribuídos:');
        print('   Nome: ${nomeLoja.value}');
        print('   CNPJ: ${cnpjCpf.value}');
        print('   Telefone: ${telefone.value}');
        print('   Descrição: ${descricao.value}');
        print('   Endereço: ${endereco.value}');
        print('   Logo URL: ${logoUrl.value}');

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

        print('🔍 [VENDOR_SETTINGS] Dados de operação atribuídos:');
        print('   Aceita fora horário: ${aceitaForaHorario.value}');
        print('   Tempo preparo: ${tempoPreparo.value}');
        print('   Mensagem boas-vindas: ${mensagemBoasVindas.value}');

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
        taxaEntrega.value = (settings['taxaEntrega'] ?? 0.0).toDouble();
        raioEntrega.value = (settings['raioEntrega'] ?? 5.0).toDouble();
        limiteEntregaGratis.value =
            (settings['limiteEntregaGratis'] ?? 100.0).toDouble();

        // Carregar estado da loja
        lojaOffline.value = settings['lojaOffline'] ?? false;

        print('🔍 [VENDOR_SETTINGS] Dados de entrega atribuídos:');
        print('   Taxa: ${taxaEntrega.value}');
        print('   Raio: ${raioEntrega.value}');
        print('   Limite Grátis: ${limiteEntregaGratis.value}');
        print(
            '🔍 [VENDOR_SETTINGS] Todos os dados foram atribuídos com sucesso!');
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
      final settingsData = {
        'nomeLoja': nomeLoja.value,
        'cnpjCpf': cnpjCpf.value,
        'descricao': descricao.value,
        'endereco': endereco.value,
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
        'lojaOffline': lojaOffline.value,
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

  Future<void> exportarRelatorioVendas() async {
    // TODO: Gerar e exportar relatório em PDF/CSV
  }

  Future<void> enviarRelatorioPorWhatsappOuEmail() async {
    // TODO: Compartilhar relatório via WhatsApp ou e-mail
  }

  Future<void> alterarSenha(String novaSenha) async {
    // TODO: Chamar backend para alterar senha
  }

  Future<void> logout() async {
    // TODO: Limpar cache, controllers, sessão e redirecionar para login
    await Get.find<AuthController>().logout();
  }

  Future<void> sincronizarComServidor() async {
    try {
      await carregarDadosLoja();

      Get.snackbar(
        'Sincronização',
        'Dados sincronizados com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Erro ao sincronizar com servidor: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível sincronizar com o servidor',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> backupManual() async {
    // TODO: Enviar backup manual para o servidor
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
