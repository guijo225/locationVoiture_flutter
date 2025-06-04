import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/paiement.dart';
import '../services/api_service.dart';

class PaiementEditDialog extends StatefulWidget {
  final Paiement paiement;

  const PaiementEditDialog({Key? key, required this.paiement}) : super(key: key);

  @override
  State<PaiementEditDialog> createState() => _PaiementEditDialogState();
}

class _PaiementEditDialogState extends State<PaiementEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _datePaiement;
  late TextEditingController _montantController;
  late String _modePaiement;
  late String _statutPaiement;

  final List<String> _modeOptions = ['espèces', 'carte', 'mobile money', 'autre'];
  final List<String> _statutOptions = ['effectué', 'en attente', 'échoué'];

  @override
  void initState() {
    super.initState();
    _datePaiement = DateTime.parse(widget.paiement.date_paiement);
    _montantController = TextEditingController(text: widget.paiement.montant.toString());
    _modePaiement = widget.paiement.mode_paiement;
    _statutPaiement = widget.paiement.statut_paiement;
  }

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le paiement'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations de base
              Text(
                'Location ID: ${widget.paiement.location_id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Date de paiement
              const Text(
                'Date de paiement',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => _selectDatePaiement(context),
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
                        DateFormat('dd/MM/yyyy').format(_datePaiement),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Montant
              TextFormField(
                controller: _montantController,
                decoration: const InputDecoration(labelText: 'Montant (€)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un montant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez saisir un nombre valide';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Le montant doit être supérieur à 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mode de paiement
              DropdownButtonFormField<String>(
                value: _modePaiement,
                decoration: const InputDecoration(labelText: 'Mode de paiement'),
                items: _modeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _modePaiement = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Statut
              DropdownButtonFormField<String>(
                value: _statutPaiement,
                decoration: const InputDecoration(labelText: 'Statut du paiement'),
                items: _statutOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _statutPaiement = newValue!;
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
          onPressed: () => _updatePaiement(),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _selectDatePaiement(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _datePaiement,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _datePaiement) {
      setState(() {
        _datePaiement = picked;
      });
    }
  }

  void _updatePaiement() async {
    if (_formKey.currentState!.validate()) {
      final updatedPaiement = Paiement(
        id: widget.paiement.id,
        location_id: widget.paiement.location_id,
        date_paiement: DateFormat('yyyy-MM-dd').format(_datePaiement),
        montant: double.parse(_montantController.text),
        mode_paiement: _modePaiement,
        statut_paiement: _statutPaiement,
      );

      final apiService = Provider.of<ApiService>(context, listen: false);
      final success = await apiService.updatePaiement(updatedPaiement);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}