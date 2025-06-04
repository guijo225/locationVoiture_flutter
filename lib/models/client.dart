class Client {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String adresse;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.adresse,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      adresse: json['adresse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'adresse': adresse,
    };
  }
}