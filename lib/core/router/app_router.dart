import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_shell.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/documents/domain/entities/document_entity.dart';
import '../../features/documents/presentation/screens/document_detail_screen.dart';
import '../../features/documents/presentation/screens/document_renewal_screen.dart';
import '../../features/documents/presentation/screens/documents_screen.dart';
import '../../features/documents/presentation/screens/register_document_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/payments/presentation/screens/new_payment_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/profiles/presentation/screens/add_edit_family_member_screen.dart';
import '../../features/profiles/presentation/screens/family_profiles_screen.dart';
import '../../features/profiles/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/personal_info_screen.dart';
import '../../features/settings/presentation/screens/security_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/support_screen.dart';
import '../../features/settings/presentation/screens/terms_policies_screen.dart';
import '../../features/wallet/domain/entities/payment_card_entity.dart';
import '../../features/wallet/domain/entities/transport_card_entity.dart';
import '../../features/wallet/presentation/screens/add_payment_card_screen.dart';
import '../../features/wallet/presentation/screens/add_transport_card_screen.dart';
import '../../features/wallet/presentation/screens/card_detail_screen.dart';
import '../../features/wallet/presentation/screens/pay_debt_screen.dart';
import '../../features/wallet/presentation/screens/recharge_transport_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Rutas de Documentos
      GoRoute(
        path: '/documents/register',
        builder: (context, state) => const RegisterDocumentScreen(),
      ),
      GoRoute(
        path: '/documents/detail',
        builder: (context, state) {
          final doc = state.extra as DocumentEntity;
          return DocumentDetailScreen(document: doc);
        },
      ),
      GoRoute(
        path: '/documents/renewal',
        builder: (context, state) {
          final doc = state.extra as DocumentEntity;
          return DocumentRenewalScreen(document: doc);
        },
      ),

      // Rutas de Billetera
      GoRoute(
        path: '/wallet/add-payment-card',
        builder: (context, state) => const AddPaymentCardScreen(),
      ),
      GoRoute(
        path: '/wallet/add-transport-card',
        builder: (context, state) => const AddTransportCardScreen(),
      ),
      GoRoute(
        path: '/wallet/card-detail',
        builder: (context, state) {
          final card = state.extra as PaymentCardEntity;
          return CardDetailScreen(card: card);
        },
      ),
      GoRoute(
        path: '/wallet/recharge',
        builder: (context, state) {
          final card = state.extra as TransportCardEntity?;
          return RechargeTransportScreen(initialCard: card);
        },
      ),
      GoRoute(
        path: '/wallet/pay-debt',
        builder: (context, state) => const PayDebtScreen(),
      ),

      // Rutas de Pagos
      GoRoute(
        path: '/payments/history',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/payments/new',
        builder: (context, state) => const NewPaymentScreen(),
      ),

      // Rutas de Perfiles Familiares
      GoRoute(
        path: '/family-profiles',
        builder: (context, state) => const FamilyProfilesScreen(),
      ),
      GoRoute(
        path: '/family-profiles/add',
        builder: (context, state) => const AddEditFamilyMemberScreen(),
      ),

      // Rutas de Configuración
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/personal-info',
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        builder: (context, state) => const SecurityScreen(),
      ),
      GoRoute(
        path: '/settings/terms',
        builder: (context, state) => const TermsPoliciesScreen(),
      ),
      GoRoute(
        path: '/settings/support',
        builder: (context, state) => const SupportScreen(),
      ),

      // Shell de Navegación con 5 ramas y preservación de estado
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // 0: Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // 1: Documentos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/documents',
                builder: (context, state) => const DocumentsScreen(),
              ),
            ],
          ),
          // 2: Billetera
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wallet',
                builder: (context, state) => const WalletScreen(),
              ),
            ],
          ),
          // 3: Notificaciones
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          // 4: Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

