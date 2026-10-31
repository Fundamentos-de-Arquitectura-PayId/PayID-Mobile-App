import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/payid_card.dart';

class TermsPoliciesScreen extends StatelessWidget {
  const TermsPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Términos y Políticas'),
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
              PayIdInfoCard(
                title: 'Términos y Condiciones de Uso',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Naturaleza del Servicio',
                      style: AppTypography.label.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PayID es una plataforma digital desarrollada para la centralización de identidad estudiantil y ciudadana, consulta de documentos, y facilitación de recargas y pagos de transporte y servicios en el territorio de la República del Perú.',
                      style: AppTypography.bodySmall.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '2. Responsabilidad de la Información',
                      style: AppTypography.label.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'El usuario garantiza que los datos de DNI, teléfono y correo ingresados son verídicos. Los documentos registrados deben corresponder a credenciales oficiales emitidas por RENIEC, SUNEDU o entidades autorizadas.',
                      style: AppTypography.bodySmall.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              PayIdInfoCard(
                title: 'Política de Privacidad y Datos',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3. Protección de Datos Personales',
                      style: AppTypography.label.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'En cumplimiento de la Ley N° 29733 (Ley de Protección de Datos Personales de Perú), tus datos no serán compartidos con terceros sin tu consentimiento expreso.',
                      style: AppTypography.bodySmall.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '4. Seguridad en Billetera y Tarjetas',
                      style: AppTypography.label.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PayID no almacena códigos CVV ni contraseñas bancarias en memoria persistente del cliente. Todas las comunicaciones con el servidor utilizan encriptación segura y tokens JWT.',
                      style: AppTypography.bodySmall.copyWith(height: 1.4),
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

