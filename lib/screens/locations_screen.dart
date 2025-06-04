import 'package:flutter/material.dart';
import 'package:myapp/widgets/location_edit_config.dart';
import 'package:provider/provider.dart';
import '../models/location.dart';
import '../services/api_service.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({Key? key}) : super(key: key);

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les locations au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiService>(context, listen: false).fetchLocations();
    });
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en cours':
        return Colors.blue;
      case 'terminée':
        return Colors.green;
      case 'annulée':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiService>(
      builder: (context, apiService, child) {
        if (apiService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (apiService.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Erreur: ${apiService.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => apiService.fetchLocations(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (apiService.locations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Aucune location disponible'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => apiService.fetchLocations(),
                  child: const Text('Actualiser'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => apiService.fetchLocations(),
          child: ListView.builder(
            itemCount: apiService.locations.length,
            itemBuilder: (context, index) {
              final location = apiService.locations[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    location.nom_client != null && location.prenom_client != null
                        ? '${location.prenom_client} ${location.nom_client}'
                        : 'Client ID: ${location.client_id}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.marque_voiture != null && location.modele_voiture != null
                            ? '${location.marque_voiture} ${location.modele_voiture}'
                            : 'Voiture ID: ${location.voiture_id}',
                      ),
                      Text(
                        'Du ${location.date_debut.substring(0, 10)} au ${location.date_fin.substring(0, 10)}',
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(location.statut_loca),
                    child: Text(
                      location.statut_loca.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(context, location),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(context, location),
                      ),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Montant total: ${location.montant_total} €'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Location location) {
    showDialog(
      context: context,
      builder: (context) => LocationEditDialog(location: location),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Location location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer cette location? Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLocation(location.id);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteLocation(int id) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final success = await apiService.deleteLocation(id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location supprimée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}