import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class InputFormatters {
  /// Máscara para telefone: (99) 99999-9999
  static final phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Máscara para CEP: 99999-999
  static final cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Máscara para CPF: 999.999.999-99
  static final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Máscara para CNPJ: 99.999.999/9999-99
  static final cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Formatter para permitir apenas números
  static final onlyNumbersFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));

  /// Formatter para permitir apenas letras e espaços
  static final onlyLettersFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]'));

  /// Formatter para permitir apenas letras, números e espaços
  static final alphanumericFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\s]'));

  /// Formatter para permitir apenas letras, números, espaços e caracteres especiais comuns
  static final addressFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\s\-\.\,\#]'));
}
