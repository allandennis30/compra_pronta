import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback? onViewAvailableDeliveries;
  final VoidCallback? onViewHistory;
  final VoidCallback? onViewProfile;
  final VoidCallback? onViewEarnings;
  final bool isAvailable;

  const QuickActionsWidget({
    super.key,
    this.onViewAvailableDeliveries,
    this.onViewHistory,
    this.onViewProfile,
    this.onViewEarnings,
    this.isAvailable = false,
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
                  Icons.flash_on,
                  color: Get.theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ações Rápidas',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildActionCard(
                  'Entregas\nDisponíveis',
                  Icons.local_shipping,
                  isAvailable ? Get.theme.primaryColor : Colors.grey,
                  onViewAvailableDeliveries,
                  enabled: isAvailable,
                ),
                _buildActionCard(
                  'Histórico de\nEntregas',
                  Icons.history,
                  Get.theme.colorScheme.secondary,
                  onViewHistory,
                ),
                _buildActionCard(
                  'Meu\nPerfil',
                  Icons.person,
                  Colors.blue,
                  onViewProfile,
                ),
                _buildActionCard(
                  'Ganhos e\nRelatórios',
                  Icons.analytics,
                  Colors.green,
                  onViewEarnings,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback? onTap, {
    bool enabled = true,
  }) {
    final effectiveColor = enabled ? color : Colors.grey;
    
    return Material(
      color: effectiveColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: effectiveColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: effectiveColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Get.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? Get.theme.colorScheme.onSurface
                      : Get.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              if (!enabled) ...[
                const SizedBox(height: 4),
                Text(
                  'Indisponível',
                  style: Get.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}