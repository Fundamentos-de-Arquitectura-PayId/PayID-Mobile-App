import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/payid_bottom_nav.dart';
import '../../features/notifications/presentation/controllers/notifications_controller.dart';

/// Shell principal con barra de navegación inferior de 5 destinos y preservación de estado
class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: navigationShell,
      bottomNavigationBar: PayIdBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        unreadNotificationsCount: unreadCount,
      ),
    );
  }
}

