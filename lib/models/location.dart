class Location {
  final int id;
  final int client_id;
  final int voiture_id;
  final String date_debut;
  final String date_fin;
  final String statut_loca;
  final double montant_total;
  final String? nom_client;
  final String? prenom_client;
  final String? marque_voiture;
  final String? modele_voiture;

  Location({
    required this.id,
    required this.client_id,
    required this.voiture_id,
    required this.date_debut,
    required this.date_fin,
    required this.statut_loca,
    required this.montant_total,
    this.nom_client,
    this.prenom_client,
    this.marque_voiture,
    this.modele_voiture,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      client_id: json['client_id'],
      voiture_id: json['voiture_id'],
      date_debut: json['date_debut'],
      date_fin: json['date_fin'],
      statut_loca: json['statut'] ?? json['statut_loca'] ?? 'en cours',
      montant_total: double.parse(json['montant_total'].toString()),
      nom_client: json['nom'],
      prenom_client: json['prenom'],
      marque_voiture: json['marque'],
      modele_voiture: json['modele'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': client_id,
      'voiture_id': voiture_id,
      'date_debut': date_debut,
      'date_fin': date_fin,
      'statut_loca': statut_loca,
      'montant_total': montant_total,
    };
  }
}