/// Validadores para formularios de PayID
class Validators {
  Validators._();

  static String? required(String? value, [String message = 'Este campo es obligatorio']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? dni(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El DNI es obligatorio';
    }
    final clean = value.trim();
    if (!RegExp(r'^\d{8}$').hasMatch(clean)) {
      return 'El DNI debe tener 8 dígitos numéricos';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    final clean = value.trim();
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(clean)) {
      return 'El correo no tiene un formato válido';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El celular es obligatorio';
    }
    final clean = value.trim();
    if (!RegExp(r'^9\d{8}$').hasMatch(clean)) {
      return 'El celular debe tener 9 dígitos y empezar con 9';
    }
    return null;
  }

  static String? emailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo o celular';
    }
    final clean = value.trim();
    final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(clean);
    final isPhone = RegExp(r'^9\d{8}$').hasMatch(clean);
    if (!isEmail && !isPhone) {
      return 'Ingresa un correo o celular peruano válido (9 dígitos)';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  static String? cardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de tarjeta es obligatorio';
    }
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    if (clean.length != 16 || !RegExp(r'^\d{16}$').hasMatch(clean)) {
      return 'El número de tarjeta debe tener 16 dígitos';
    }
    return null;
  }

  static String? cvv(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El CVV es obligatorio';
    }
    final clean = value.trim();
    if (clean.length < 3 || clean.length > 4 || !RegExp(r'^\d+$').hasMatch(clean)) {
      return 'El CVV debe tener 3 o 4 dígitos';
    }
    return null;
  }

  static String? expiryDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La fecha de vencimiento es obligatoria';
    }
    final clean = value.trim();
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(clean)) {
      return 'Usa el formato MM/AA (ej: 12/28)';
    }
    return null;
  }

  static String? positiveAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa un monto';
    }
    final amount = double.tryParse(value.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      return 'El monto debe ser mayor a S/ 0.00';
    }
    return null;
  }
}

