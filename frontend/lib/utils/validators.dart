String? validateEmail(String? v) {
  final value = v?.trim() ?? '';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  return ok ? null : 'Email invalide';
}

String? validatePassword(String? v) =>
    (v == null || v.length < 8) ? '8 caractères minimum' : null;

String? validateRequired(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;
