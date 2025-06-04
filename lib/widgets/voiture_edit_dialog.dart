import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/voiture.dart';
import '../services/api_service.dart';

class VoitureEditDialog extends StatefulWidget {
  final Voiture voiture;

  const VoitureEditDialog({Key? key, required this.voiture}) : super(key: key);

  @override
  State<VoitureEditDialog> createState() => _VoitureEditDialogState();
}

class _VoitureEditDialogState extends State<VoitureEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _marqueController;
  late TextEditingController _modeleController;
  late TextEditingController _immatriculationController;
  late TextEditingController _couleurController;
  late TextEditingController _prixJournalierController;
  late String _statut;

  final List<String> _statutOptions = ['disponible', 'louée', 'maintenance'];

  @override
  void initState() {
    super.initState();
    _marqueController = TextEditingController(text: widget.voiture.marque);
    _modeleController = TextEditingController(text: widget.voiture.modele);
    _immatriculationController = TextEditingController(text: widget.voiture.immatriculation);
    _couleurController = TextEditingController(text: widget.voiture.couleur);
    _prixJournalierController = TextEditingController(text: widget.voiture.prix_journalier.toString());
    _statut = widget.voiture.statut;
  }

  @override
  void dispose() {
    _marqueController.dispose();
    _modeleController.dispose();
    _immatriculationController.dispose();
    _couleurController.dispose();
    _prixJournalierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la voiture'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _marqueController,
                decoration: const InputDecoration(labelText: 'Marque'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une marque';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _modeleController,
                decoration: const InputDecoration(labelText: 'Modèle'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un modèle';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _immatriculationController,
                decoration: const InputDecoration(labelText: 'Immatriculation'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une immatriculation';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _couleurController,
                decoration: const InputDecoration(labelText: 'Couleur'),
              ),
              DropdownButtonFormField<String>(
                value: _statut,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: _statutOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _statut = newValue!;
                  });
                },
              ),
              TextFormField(
                controller: _prixJournalierController,
                decoration: const InputDecoration(labelText: 'Prix journalier (€)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez saisir un nombre valide';
                  }
                  if (double.parse(value) < 0) {
                    return 'Le prix ne peut pas être négatif';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => _updateVoiture(),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _updateVoiture() async {
    if (_formKey.currentState!.validate()) {
      final updatedVoiture = Voiture(
        id: widget.voiture.id,
        marque: _marqueController.text,
        modele: _modeleController.text,
        immatriculation: _immatriculationController.text,
        couleur: _couleurController.text,
        statut: _statut,
        prix_journalier: double.parse(_prixJournalierController.text),
      );

      final apiService = Provider.of<ApiService>(context, listen: false);
      final success = await apiService.updateVoiture(updatedVoiture);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voiture mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}