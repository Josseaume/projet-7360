/// Ressource d'exemple : à renommer / adapter selon le métier du projet.
class Item {
  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.done,
  });

  final int id;
  final String title;
  final String description;
  final bool done;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] as int,
    title: json['title'] as String,
    description: (json['description'] as String?) ?? '',
    done: json['done'] as bool,
  );
}
