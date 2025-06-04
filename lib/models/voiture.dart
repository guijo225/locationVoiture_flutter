class Voiture {
  final int id;
  final String marque;
  final String modele;
  final String immatriculation;
  final String couleur;
  final String statut;
  final double prix_journalier;

  Voiture({
    required this.id,
    required this.marque,
    required this.modele,
    required this.immatriculation,
    required this.couleur,
    required this.statut,
    required this.prix_journalier,
  });

  factory Voiture.fromJson(Map<String, dynamic> json) {
    return Voiture(
      id: json['id'],
      marque: json['marque'],
      modele: json['modele'],
      immatriculation: json['immatriculation'],
      couleur: json['couleur'] ?? '',
      statut: json['statut'] ?? 'disponible',
      prix_journalier: double.parse(json['prix_journalier'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marque': marque,
      'modele': modele,
      'immatriculation': immatriculation,
      'couleur': couleur,
      'statut': statut,
      'prix_journalier': prix_journalier,
    };
  }
}