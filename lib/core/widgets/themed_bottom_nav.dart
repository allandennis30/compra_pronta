import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

/// Widget de navegação inferior que reage automaticamente ao tema
class ThemedBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<ThemedBottomNavItem> items;
  final Function(int)? onTap;

  const ThemedBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = currentIndex == index;
              
              return _buildNavItem(
                context,
                item: item,
                isActive: isActive,
                onTap: () => onTap?.call(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required ThemedBottomNavItem item,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
                         padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: 24,
                    color: isActive 
                        ? primaryColor 
                        : AppColors.bottomNavUnselected(context),
                  ),
                ),
                                 const SizedBox(height: 1),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive 
                        ? primaryColor 
                        : AppColors.bottomNavUnselected(context),
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Item da navegação inferior
class ThemedBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const ThemedBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Widget de navegação inferior com badge (para carrinho, notificações, etc.)
class ThemedBottomNavWithBadge extends StatelessWidget {
  final int currentIndex;
  final List<ThemedBottomNavItemWithBadge> items;
  final Function(int)? onTap;

  const ThemedBottomNavWithBadge({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = currentIndex == index;
              
              return _buildNavItemWithBadge(
                context,
                item: item,
                isActive: isActive,
                onTap: () => onTap?.call(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(
    BuildContext context, {
    required ThemedBottomNavItemWithBadge item,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
                         padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: 24,
                        color: isActive 
                            ? primaryColor 
                            : AppColors.bottomNavUnselected(context),
                      ),
                    ),
                    if (item.badgeCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.error(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            item.badgeCount > 99 ? '99+' : item.badgeCount.toString(),
                            style: TextStyle(
                              color: AppColors.onSurface(context),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                                 const SizedBox(height: 1),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive 
                        ? primaryColor 
                        : AppColors.bottomNavUnselected(context),
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Item da navegação inferior com badge
class ThemedBottomNavItemWithBadge {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;

  const ThemedBottomNavItemWithBadge({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
  });
}
