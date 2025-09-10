import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvailabilityToggleWidget extends StatelessWidget {
  final bool isAvailable;
  final bool isLoading;
  final VoidCallback onToggle;
  final String? statusMessage;

  const AvailabilityToggleWidget({
    super.key,
    required this.isAvailable,
    required this.onToggle,
    this.isLoading = false,
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAvailable ? Icons.work : Icons.work_off,
                  color: isAvailable ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status de Disponibilidade',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAvailable ? 'Disponível para Entregas' : 'Indisponível',
                        style: Get.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isAvailable ? Colors.green : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusMessage ??
                            (isAvailable
                                ? 'Você está recebendo pedidos de entrega'
                                : 'Você não está recebendo novos pedidos'),
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildToggleSwitch(),
              ],
            ),
            if (isAvailable) ...[
              const SizedBox(height: 16),
              _buildAvailableInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAvailable ? Colors.green : Colors.grey,
          width: 2,
        ),
      ),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          : Switch(
              value: isAvailable,
              onChanged: (_) => onToggle(),
              activeColor: Colors.white,
              activeTrackColor: Colors.green,
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
    );
  }

  Widget _buildAvailableInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Você receberá notificações de novos pedidos próximos à sua localização.',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}