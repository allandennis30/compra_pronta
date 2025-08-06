// ignore_for_file: file_names
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/horario_funcionamento.dart';

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
  var horarioInicio = TimeOfDay(hour: 8, minute: 0).obs;
  var horarioFim = TimeOfDay(hour: 18, minute: 0).obs;
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

  bool get isVendor => Get.find<AuthController>().isVendor;

  Future<void> carregarDadosLoja() async {
    // TODO: Buscar dados do backend e popular os campos acima

    // Inicializar horários de funcionamento para cada dia da semana
    if (horariosFuncionamento.isEmpty) {
      _inicializarHorariosFuncionamento();
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
    // TODO: Enviar dados editados para o backend
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
    // TODO: Recarregar dados da loja, produtos e pedidos do backend
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
