import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/location.dart';
import '../services/api_service.dart';

class LocationEditDialog extends StatefulWidget {
  final Location location;

  const LocationEditDialog({Key? key, required this.location}) : super(key: key);

  @override
  State<LocationEditDialog> createState() => _LocationEditDialogState();
}

class _LocationEditDialogState extends State<LocationEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _dateDebut;
  late DateTime _dateFin;
  late String _statut;

  final List<String> _statutOptions = ['en cours', 'terminée', 'annulée'];

  @override
  void initState() {
    super.initState();
    _dateDebut = DateTime.parse(widget.location.date_debut);
    _dateFin = DateTime.parse(widget.location.date_fin);
    _statut = widget.location.statut_loca;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la location'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations client et voiture (non modifiables)
              const Text(
                'Informations',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Client: ${widget.location.nom_client ?? ''} ${widget.location.prenom_client ?? ''} (ID: ${widget.location.client_id})',
              ),
              Text(
                'Voiture: ${widget.location.marque_voiture ?? ''} ${widget.location.modele_voiture ?? ''} (ID: ${widget.location.voiture_id})',
              ),
              Text(
                'Montant total: ${widget.location.montant_total} €',
              ),
              const SizedBox(height: 16),

              // Date de début
              const Text(
                'Date de début',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => _selectDateDebut(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(_dateDebut),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date de fin
              const Text(
                'Date de fin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => _selectDateFin(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(_dateFin),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Statut
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
          onPressed: () => _updateLocation(),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _selectDateDebut(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _dateDebut) {
      setState(() {
        _dateDebut = picked;
        // Si la date de début est après la date de fin, mettre à jour la date de fin
        if (_dateDebut.isAfter(_dateFin)) {
          _dateFin = _dateDebut;
        }
      });
    }
  }

  Future<void> _selectDateFin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFin.isAfter(_dateDebut) ? _dateFin : _dateDebut,
      firstDate: _dateDebut,
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _dateFin) {
      setState(() {
        _dateFin = picked;
      });
    }
  }

  void _updateLocation() async {
    if (_formKey.currentState!.validate()) {
      final updatedLocation = Location(
        id: widget.location.id,
        client_id: widget.location.client_id,
        voiture_id: widget.location.voiture_id,
        date_debut: DateFormat('yyyy-MM-dd').format(_dateDebut),
        date_fin: DateFormat('yyyy-MM-dd').format(_dateFin),
        statut_loca: _statut,
        montant_total: widget.location.montant_total,
        nom_client: widget.location.nom_client,
        prenom_client: widget.location.prenom_client,
        marque_voiture: widget.location.marque_voiture,
        modele_voiture: widget.location.modele_voiture,
      );

      final apiService = Provider.of<ApiService>(context, listen: false);
      final success = await apiService.updateLocation(updatedLocation);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}