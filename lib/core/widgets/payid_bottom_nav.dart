import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

/// Barra de navegación inferior oficial con 5 destinos para PayID
class PayIdBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadNotificationsCount;

  const PayIdBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadNotificationsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.line,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Inicio',
                icon: LucideIcons.home,
              ),
              _buildNavItem(
                index: 1,
                label: 'Documentos',
                icon: LucideIcons.fileText,
              ),
              _buildNavItem(
                index: 2,
                label: 'Billetera',
                icon: LucideIcons.wallet,
              ),
              _buildNavItem(
                index: 3,
                label: 'Alertas',
                icon: LucideIcons.bell,
                badgeCount: unreadNotificationsCount,
              ),
              _buildNavItem(
                index: 4,
                label: 'Perfil',
                icon: LucideIcons.user,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryInstitutional : AppColors.brandGray;

    return Expanded(
      child: Semantics(
        selected: isSelected,
        label: label,
        button: true,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: AppColors.mint50,
          highlightColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(
              minWidth: AppDimensions.minTouchTarget,
              minHeight: AppDimensions.minTouchTarget,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: AppDimensions.iconNavigation,
                      color: color,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -6,
                        top: -3,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            badgeCount > 9 ? '9+' : '$badgeCount',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  label,
                  style: isSelected
                      ? AppTypography.label.copyWith(
                          fontSize: 12,
                          color: AppColors.primaryInstitutional,
                        )
                      : AppTypography.helper.copyWith(
                          fontSize: 12,
                          color: AppColors.brandGray,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

