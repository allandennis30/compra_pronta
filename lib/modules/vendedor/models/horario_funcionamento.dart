import 'package:flutter/material.dart';

class HorarioFuncionamento {
  final bool ativo;
  final TimeOfDay horarioInicio;
  final TimeOfDay horarioFim;

  const HorarioFuncionamento({
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

  // Método para criar a partir de JSON
  factory HorarioFuncionamento.fromJson(Map<String, dynamic> json) {
    TimeOfDay horarioInicio = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay horarioFim = const TimeOfDay(hour: 18, minute: 0);

    if (json['horarioInicio'] != null) {
      final horarioInicioStr = json['horarioInicio'];
      if (horarioInicioStr is String) {
        final parts = horarioInicioStr.split(':');
        if (parts.length == 2) {
          horarioInicio = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    }

    if (json['horarioFim'] != null) {
      final horarioFimStr = json['horarioFim'];
      if (horarioFimStr is String) {
        final parts = horarioFimStr.split(':');
        if (parts.length == 2) {
          horarioFim = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    }

    return HorarioFuncionamento(
      ativo: json['ativo'] ?? true,
      horarioInicio: horarioInicio,
      horarioFim: horarioFim,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'ativo': ativo,
      'horarioInicio':
          '${horarioInicio.hour.toString().padLeft(2, '0')}:${horarioInicio.minute.toString().padLeft(2, '0')}',
      'horarioFim':
          '${horarioFim.hour.toString().padLeft(2, '0')}:${horarioFim.minute.toString().padLeft(2, '0')}',
    };
  }
}
