import 'package:flutter/material.dart';

class QuantitySelectorWidget extends StatefulWidget {
  final int quantity;
  final int maxQuantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isSoldByWeight;
  final double? weight;

  const QuantitySelectorWidget({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.onIncrement,
    required this.onDecrement,
    this.isSoldByWeight = false,
    this.weight,
  });

  @override
  State<QuantitySelectorWidget> createState() => _QuantitySelectorWidgetState();
}

class _QuantitySelectorWidgetState extends State<QuantitySelectorWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: _buildQuantitySelector(context),
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHighest,
            Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.isSoldByWeight ? Icons.scale : Icons.inventory_2,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isSoldByWeight ? 'Peso' : 'Quantidade',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isSoldByWeight
                      ? 'Selecione o peso em kg'
                      : 'Máx: ${widget.maxQuantity} unidades',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _buildQuantityControls(context),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildQuantityButton(
            context: context,
            icon: Icons.remove,
            onPressed: widget.isSoldByWeight
                ? (widget.weight != null && widget.weight! > 0.1 ? widget.onDecrement : null)
                : (widget.quantity > 1 ? widget.onDecrement : null),
          ),
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              widget.isSoldByWeight
                  ? '${(widget.weight ?? 0.0).toStringAsFixed(1)}kg'
                  : widget.quantity.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          _buildQuantityButton(
            context: context,
            icon: Icons.add,
            onPressed: widget.isSoldByWeight
                ? widget.onIncrement
                : (widget.quantity < widget.maxQuantity ? widget.onIncrement : null),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: onPressed != null
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

}
