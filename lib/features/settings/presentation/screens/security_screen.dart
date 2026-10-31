import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/payid_card.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricsEnabled = true;
  bool _offlineCacheEncryption = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Seguridad y Privacidad'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: AppDimensions.iconNavigation),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PayIdSecurityCard(
                title: 'Protección Antifraude Activa',
                message:
                    'Tras 5 intentos fallidos consecutivos de contraseña, el acceso se bloquea temporalmente por 15 minutos para proteger tu billetera y datos de identidad.',
                type: SecurityCardType.success,
              ),
              const SizedBox(height: AppDimensions.space24),

              PayIdInfoCard(
                title: 'Preferencias de Seguridad',
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _biometricsEnabled,
                      activeTrackColor: AppColors.primaryInstitutional,
                      title: Text(
                        'Desbloqueo Biométrico / Huella',
                        style: AppTypography.label.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Permitir autenticación rápida en este dispositivo',
                        style: AppTypography.helper,
                      ),
                      onChanged: (val) => setState(() => _biometricsEnabled = val),
                    ),
                    const Divider(),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _offlineCacheEncryption,
                      activeTrackColor: AppColors.primaryInstitutional,
                      title: Text(
                        'Encriptación de Documentos Offline',
                        style: AppTypography.label.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Almacenamiento seguro cifrado en el dispositivo',
                        style: AppTypography.helper,
                      ),
                      onChanged: (val) => setState(() => _offlineCacheEncryption = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              PayIdInfoCard(
                title: 'Criptografía y Sesión',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• Token JWT almacenado en almacenamiento seguro de hardware (Keystore / Keychain).',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• No se almacena CVV de tarjetas ni contraseñas bancarias en texto plano.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Todas las conexiones viajan mediante canal HTTPS / TLS cifrado.',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }
}
