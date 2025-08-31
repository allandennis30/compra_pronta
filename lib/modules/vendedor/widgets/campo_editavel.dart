import 'package:flutter/material.dart';

class CampoEditavel extends StatefulWidget {
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
    super.key,
  });

  @override
  State<CampoEditavel> createState() => _CampoEditavelState();
}

class _CampoEditavelState extends State<CampoEditavel> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.valor);
  }

  @override
  void didUpdateWidget(CampoEditavel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valor != widget.valor) {
      _controller.text = widget.valor;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
            labelText: widget.label, border: OutlineInputBorder()),
        onChanged: widget.onChanged,
        maxLines: widget.maxLines,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
      ),
    );
  }
}
