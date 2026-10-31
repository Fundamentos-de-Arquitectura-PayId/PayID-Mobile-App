import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_logo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': LucideIcons.fileCheck,
      'title': 'Identidad digital segura',
      'description':
          'Centraliza tu DNI, carné universitario y documentos personales y familiares en un solo lugar con acceso inmediato.',
    },
    {
      'icon': LucideIcons.creditCard,
      'title': 'Billetera y transporte',
      'description':
          'Consulta tus saldos, recarga tarjetas de Metropolitano y Metro de Lima de forma instantánea y paga deudas sin filas.',
    },
    {
      'icon': LucideIcons.shieldCheck,
      'title': 'Control y tranquilidad',
      'description':
          'Recibe notificaciones sobre vencimientos de documentos, trámites en curso y controla tus operaciones en soles peruanos.',
    },
  ];

  Future<void> _completeOnboarding() async {
    final storage = ref.read(secureStorageProvider);
    await storage.setOnboardingSeen(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.space24),
              const Align(
                alignment: Alignment.centerLeft,
                child: PayIdLogo(size: PayIdLogoSize.small),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.mint50,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
                            border: Border.all(color: AppColors.mint200, width: 1.5),
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            size: 48,
                            color: AppColors.primaryInstitutional,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space32),
                        Text(
                          slide['title'] as String,
                          style: AppTypography.heading2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.space16),
                        Text(
                          slide['description'] as String,
                          style: AppTypography.lead.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Indicadores de página
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryInstitutional
                          : AppColors.line,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space32),

              // Botones de acción
              PayIdButton(
                text: _currentPage == _slides.length - 1 ? 'Crear mi cuenta' : 'Continuar',
                size: PayIdButtonSize.l,
                onPressed: () async {
                  if (_currentPage < _slides.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    await _completeOnboarding();
                    if (context.mounted) context.go('/register');
                  }
                },
              ),
              const SizedBox(height: AppDimensions.space12),

              PayIdButton(
                text: 'Ya tengo una cuenta',
                variant: PayIdButtonVariant.secondary,
                size: PayIdButtonSize.l,
                onPressed: () async {
                  await _completeOnboarding();
                  if (context.mounted) context.go('/login');
                },
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }
}

