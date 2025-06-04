import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/client.dart';
import '../models/voiture.dart';
import '../models/location.dart';
import '../models/paiement.dart';

class ApiService extends ChangeNotifier {
  // URLs des API
  final String nodeBaseUrl =
      'http://192.168.252.229:3000/api'; // Pour l'émulateur Android
  final String laravelBaseUrl =
      'http://192.168.252.229:8000/api'; // Pour l'émulateur Android

  // Listes de données
  List<Client> _clients = [];
  List<Voiture> _voitures = [];
  List<Location> _locations = [];
  List<Paiement> _paiements = [];

  // Getters
  List<Client> get clients => _clients;
  List<Voiture> get voitures => _voitures;
  List<Location> get locations => _locations;
  List<Paiement> get paiements => _paiements;

  // État du chargement
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Erreur
  String _error = '';
  String get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String message) {
    _error = message;
    notifyListeners();
  }

  // Fonctions pour l'API Node.js (lecture)

  Future<void> fetchClients() async {
    try {
      setLoading(true);
      final response = await http.get(Uri.parse('$nodeBaseUrl/clients'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _clients = data.map((item) => Client.fromJson(item)).toList();
        notifyListeners();
      } else {
        setError(
          'Erreur lors de la récupération des clients: ${response.statusCode}',
        );
      }
    } catch (e) {
      setError('Exception lors de la récupération des clients: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchVoitures() async {
    try {
      setLoading(true);
      final response = await http.get(Uri.parse('$nodeBaseUrl/voitures'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _voitures = data.map((item) => Voiture.fromJson(item)).toList();
        notifyListeners();
      } else {
        setError(
          'Erreur lors de la récupération des voitures: ${response.statusCode}',
        );
      }
    } catch (e) {
      setError('Exception lors de la récupération des voitures: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchLocations() async {
    try {
      setLoading(true);
      final response = await http.get(Uri.parse('$nodeBaseUrl/locations'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _locations = data.map((item) => Location.fromJson(item)).toList();
        notifyListeners();
      } else {
        setError(
          'Erreur lors de la récupération des locations: ${response.statusCode}',
        );
      }
    } catch (e) {
      setError('Exception lors de la récupération des locations: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchPaiements() async {
    try {
      setLoading(true);
      final response = await http.get(Uri.parse('$nodeBaseUrl/paiements'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _paiements = data.map((item) => Paiement.fromJson(item)).toList();
        notifyListeners();
      } else {
        setError(
          'Erreur lors de la récupération des paiements: ${response.statusCode}',
        );
      }
    } catch (e) {
      setError('Exception lors de la récupération des paiements: $e');
    } finally {
      setLoading(false);
    }
  }

  // Fonctions pour l'API Laravel (mise à jour et suppression)

  // Clients
  Future<bool> updateClient(Client client) async {
    try {
      setLoading(true);
      final response = await http.put(
        Uri.parse('$laravelBaseUrl/client/${client.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(client.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchClients(); // Rafraîchir les données
        return true;
      } else {
        setError(
          'Erreur lors de la mise à jour du client: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      setError('Exception lors de la mise à jour du client: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteClient(int id) async {
    try {
      setLoading(true);
      final response = await http.delete(
        Uri.parse('$laravelBaseUrl/client/$id'),
      );

      if (response.statusCode == 204) {
        _clients.removeWhere((client) => client.id == id);
        notifyListeners();
        return true;
      } else {
        setError(
          'Erreur lors de la suppression du client: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      setError('Exception lors de la suppression du client: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Voitures
  Future<bool> updateVoiture(Voiture voiture) async {
    try {
      setLoading(true);
      final response = await http.put(
        Uri.parse('$laravelBaseUrl/voiture/${voiture.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(voiture.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchVoitures(); // Rafraîchir les données
        return true;
      } else {
        setError(
          'Erreur lors de la mise à jour de la voiture: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      setError('Exception lors de la mise à jour de la voiture: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteVoiture(int id) async {
    try {
      setLoading(true);
      final response = await http.delete(
        Uri.parse('$laravelBaseUrl/voiture/$id'),
      );

      if (response.statusCode == 204) {
        _voitures.removeWhere((voiture) => voiture.id == id);
        notifyListeners();
        return true;
      } else {
        setError(
          'Erreur lors de la suppression de la voiture: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      setError('Exception lors de la suppression de la voiture: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Locations
  Future<bool> updateLocation(Location location) async {
    try {
      setLoading(true);
      final response = await http.put(
        Uri.parse('$laravelBaseUrl/location/${location.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(location.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchLocations(); // Rafraîchir les données
        return true;
      } else {
        setError(
          'Erreur lors de la mise à jour de la location: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      setError('Exception lors de la mise à jour de la location: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteLocation(int id) async {
    try {
      setLoading(true);
      final response = await http.delete(
        Uri.parse('$laravelBaseUrl/location/$id'),
      );

      if (response.statusCode == 204) {
        _locations.removeWhere((location) => location.id == id);
        notifyListeners();
        return true;
      } else {
        setError(
          'Erreur lors de la suppression de la location: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      setError('Exception lors de la suppression de la location: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Paiements
  Future<bool> updatePaiement(Paiement paiement) async {
    try {
      setLoading(true);
      final response = await http.put(
        Uri.parse('$laravelBaseUrl/paiement/${paiement.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(paiement.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchPaiements(); // Rafraîchir les données
        return true;
      } else {
        setError(
          'Erreur lors de la mise à jour du paiement: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      setError('Exception lors de la mise à jour du paiement: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deletePaiement(int id) async {
    try {
      setLoading(true);
      final response = await http.delete(
        Uri.parse('$laravelBaseUrl/paiement/$id'),
      );

      if (response.statusCode == 204) {
        _paiements.removeWhere((paiement) => paiement.id == id);
        notifyListeners();
        return true;
      } else {
        setError(
          'Erreur lors de la suppression du paiement: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      setError('Exception lors de la suppression du paiement: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
}