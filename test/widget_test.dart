import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payid_mobile/core/utils/currency_formatter.dart';
import 'package:payid_mobile/core/utils/validators.dart';
import 'package:payid_mobile/core/widgets/payid_badge.dart';
import 'package:payid_mobile/core/widgets/payid_button.dart';
import 'package:payid_mobile/core/widgets/payid_card.dart';

void main() {
  group('PayID Utils & Formatters Unit Tests', () {
    test('CurrencyFormatter formats PEN currency properly', () {
      final formatted = CurrencyFormatter.format(1250.50);
      // print('FORMATTED OUTPUT: $formatted');
      expect(formatted.contains('S/'), isTrue);
      expect(formatted.contains('50'), isTrue);
    });

    test('CurrencyFormatter masks credit card numbers correctly', () {
      final masked = CurrencyFormatter.maskCardNumber('4557123456789012');
      expect(masked, '•••• •••• •••• 9012');
    });

    test('Validators validate Peruvian DNI (8 digits)', () {
      expect(Validators.dni('12345678'), isNull);
      expect(Validators.dni('1234567'), isNotNull);
      expect(Validators.dni('123456789'), isNotNull);
      expect(Validators.dni('abcd5678'), isNotNull);
      expect(Validators.dni(''), isNotNull);
    });

    test('Validators validate Peruvian phone numbers (9 digits, starts with 9)', () {
      expect(Validators.phone('987654321'), isNull);
      expect(Validators.phone('887654321'), isNotNull);
      expect(Validators.phone('98765432'), isNotNull);
      expect(Validators.phone(''), isNotNull);
    });

    test('Validators validate passwords with minimum 8 characters', () {
      expect(Validators.password('12345678'), isNull);
      expect(Validators.password('pass1234'), isNull);
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password(''), isNotNull);
    });

    test('Validators validate card numbers (16 digits)', () {
      expect(Validators.cardNumber('4557123456789012'), isNull);
      expect(Validators.cardNumber('4557 1234 5678 9012'), isNull);
      expect(Validators.cardNumber('123'), isNotNull);
    });
  });

  group('PayID UI Widgets Tests', () {
    testWidgets('PayIdButton renders primary variant with institutional green', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayIdButton(
              text: 'Ingresar a PayID',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Ingresar a PayID'), findsOneWidget);
    });

    testWidgets('PayIdButton shows loading spinner and text during operations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayIdButton(
              text: 'Ingresar',
              isLoading: true,
              loadingText: 'Verificando...',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Verificando...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('PayIdBadge displays semantic variants', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PayIdBadge(
              text: 'Verificado',
              variant: PayIdBadgeVariant.success,
            ),
          ),
        ),
      );

      expect(find.text('Verificado'), findsOneWidget);
    });

    testWidgets('PayIdSecurityCard displays security alerts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PayIdSecurityCard(
              title: 'Aviso de Seguridad',
              message: 'Cuenta bloqueada temporalmente por 15 minutos.',
              type: SecurityCardType.error,
            ),
          ),
        ),
      );

      expect(find.text('Aviso de Seguridad'), findsOneWidget);
      expect(find.text('Cuenta bloqueada temporalmente por 15 minutos.'), findsOneWidget);
    });
  });
}
