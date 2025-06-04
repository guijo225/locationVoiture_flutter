import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/voiture.dart';
import '../services/api_service.dart';
import 'package:myapp/widgets/voiture_edit_dialog.dart';

class VoituresScreen extends StatefulWidget {
  const VoituresScreen({Key? key}) : super(key: key);

  @override
  State<VoituresScreen> createState() => _VoituresScreenState();
}

class _VoituresScreenState extends State<VoituresScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les voitures au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiService>(context, listen: false).fetchVoitures();
    });
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'disponible':
        return Colors.green;
      case 'louée':
        return Colors.orange;
      case 'maintenance':
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
                  onPressed: () => apiService.fetchVoitures(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (apiService.voitures.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Aucune voiture disponible'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => apiService.fetchVoitures(),
                  child: const Text('Actualiser'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => apiService.fetchVoitures(),
          child: ListView.builder(
            itemCount: apiService.voitures.length,
            itemBuilder: (context, index) {
              final voiture = apiService.voitures[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('${voiture.marque} ${voiture.modele}'),
                  subtitle: Text('Immatriculation: ${voiture.immatriculation}'),
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(voiture.statut),
                    child: Text(
                      voiture.statut.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(context, voiture),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(context, voiture),
                      ),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Prix journalier: ${voiture.prix_journalier} € - Couleur: ${voiture.couleur}'),
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

  void _showEditDialog(BuildContext context, Voiture voiture) {
    showDialog(
      context: context,
      builder: (context) => VoitureEditDialog(voiture: voiture),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Voiture voiture) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer la voiture ${voiture.marque} ${voiture.modele} (${voiture.immatriculation}) ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteVoiture(voiture.id);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteVoiture(int id) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final success = await apiService.deleteVoiture(id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voiture supprimée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}