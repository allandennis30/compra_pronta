import 'package:flutter/material.dart';

class HorarioFuncionamento {
  final bool ativo;
  final TimeOfDay horarioInicio;
  final TimeOfDay horarioFim;

  HorarioFuncionamento({
    this.ativo = true,
    required this.horarioInicio,
    required this.horarioFim,
  });

  // Método para criar uma cópia com valores atualizados
  HorarioFuncionamento copyWith({
    bool? ativo,
    TimeOfDay? horarioInicio,
    TimeOfDay? horarioFim,
  }) {
    return HorarioFuncionamento(
      ativo: ativo ?? this.ativo,
      horarioInicio: horarioInicio ?? this.horarioInicio,
      horarioFim: horarioFim ?? this.horarioFim,
    );
  }
}
