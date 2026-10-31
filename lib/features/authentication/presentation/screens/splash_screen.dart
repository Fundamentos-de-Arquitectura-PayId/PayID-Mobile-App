import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/widgets/payid_logo.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final storage = ref.read(secureStorageProvider);
    final seenOnboarding = await storage.isOnboardingSeen();
    final authState = ref.read(authControllerProvider);

    if (authState.isAuthenticated) {
      if (mounted) context.go('/dashboard');
    } else if (!seenOnboarding) {
      if (mounted) context.go('/onboarding');
    } else {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PayIdLogo(
              size: PayIdLogoSize.large,
              showTagline: true,
            ),
            SizedBox(height: AppDimensions.space32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryInstitutional,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

