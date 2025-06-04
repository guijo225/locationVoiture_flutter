import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paiement.dart';
import '../services/api_service.dart';
import '../widgets/paiement_edit_dialog.dart';

class PaiementsScreen extends StatefulWidget {
  const PaiementsScreen({Key? key}) : super(key: key);

  @override
  State<PaiementsScreen> createState() => _PaiementsScreenState();
}

class _PaiementsScreenState extends State<PaiementsScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les paiements au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiService>(context, listen: false).fetchPaiements();
    });
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'effectué':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'échoué':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'espèces':
        return Icons.money;
      case 'carte':
        return Icons.credit_card;
      case 'mobile money':
        return Icons.phone_android;
      default:
        return Icons.payment;
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
                  onPressed: () => apiService.fetchPaiements(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (apiService.paiements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Aucun paiement disponible'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => apiService.fetchPaiements(),
                  child: const Text('Actualiser'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => apiService.fetchPaiements(),
          child: ListView.builder(
            itemCount: apiService.paiements.length,
            itemBuilder: (context, index) {
              final paiement = apiService.paiements[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('Location ID: ${paiement.location_id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${paiement.date_paiement.substring(0, 10)}'),
                      Text('Montant: ${paiement.montant} €'),
                    ],
                  ),
                  isThreeLine: true,
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(paiement.statut_paiement),
                    child: Icon(
                      _getPaymentIcon(paiement.mode_paiement),
                      color: Colors.white,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(context, paiement),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(context, paiement),
                      ),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mode de paiement: ${paiement.mode_paiement} - Statut: ${paiement.statut_paiement}'),
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

  void _showEditDialog(BuildContext context, Paiement paiement) {
    showDialog(
      context: context,
      builder: (context) => PaiementEditDialog(paiement: paiement),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Paiement paiement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer ce paiement de ${paiement.montant} € pour la location ${paiement.location_id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePaiement(paiement.id);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deletePaiement(int id) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final success = await apiService.deletePaiement(id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paiement supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}