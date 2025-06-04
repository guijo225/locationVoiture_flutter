class Paiement {
  final int id;
  final int location_id;
  final String date_paiement;
  final double montant;
  final String mode_paiement;
  final String statut_paiement;

  Paiement({
    required this.id,
    required this.location_id,
    required this.date_paiement,
    required this.montant,
    required this.mode_paiement,
    required this.statut_paiement,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'],
      location_id: json['location_id'],
      date_paiement: json['date_paiement'],
      montant: double.parse(json['montant'].toString()),
      mode_paiement: json['mode_paiement'],
      statut_paiement: json['statut'] ?? json['statut_paiement'] ?? 'en attente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_id': location_id,
      'date_paiement': date_paiement,
      'montant': montant,
      'mode_paiement': mode_paiement,
      'statut_paiement': statut_paiement,
    };
  }
}