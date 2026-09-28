class User {
  const User({required this.id, required this.email, required this.fullName});

  final int id;
  final String email;
  final String fullName;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    email: json['email'] as String,
    fullName: (json['full_name'] as String?) ?? '',
  );

  /// Nom à afficher : le nom complet, sinon l'email.
  String get displayName => fullName.isNotEmpty ? fullName : email;
}
