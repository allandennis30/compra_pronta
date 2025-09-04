import 'package:flutter/material.dart';

class CampoEditavel extends StatefulWidget {
  final String label;
  final String valor;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final bool enabled;
  final TextInputType? keyboardType;
  final String Function(String rawText)? onBlurFormat;

  const CampoEditavel({
    required this.label,
    required this.valor,
    required this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.keyboardType,
    this.onBlurFormat,
    super.key,
  });

  @override
  State<CampoEditavel> createState() => _CampoEditavelState();
}

class _CampoEditavelState extends State<CampoEditavel> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.valor);
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && widget.onBlurFormat != null) {
      final formatted = widget.onBlurFormat!.call(_controller.text);
      if (formatted.isNotEmpty) {
        _controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  @override
  void didUpdateWidget(CampoEditavel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Avoid overriding user input while the field is focused
    if (oldWidget.valor != widget.valor && !_focusNode.hasFocus) {
      _controller.text = widget.valor;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
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
