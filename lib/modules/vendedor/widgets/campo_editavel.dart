import 'package:flutter/material.dart';

class CampoEditavel extends StatelessWidget {
  final String label;
  final String valor;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final bool enabled;
  final TextInputType? keyboardType;

  const CampoEditavel({
    required this.label,
    required this.valor,
    required this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.keyboardType,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: valor,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        onChanged: onChanged,
        maxLines: maxLines,
        enabled: enabled,
        keyboardType: keyboardType,
      ),
    );
  }
}
