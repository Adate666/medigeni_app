import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../models/user.dart';
import '../../models/medical_data.dart';
import '../../theme/app_theme.dart';

class PeriodTracker extends StatefulWidget {
  const PeriodTracker({super.key});

  @override
  State<PeriodTracker> createState() => _PeriodTrackerState();
}

class _PeriodTrackerState extends State<PeriodTracker> {
  final _cycleLengthController = TextEditingController(text: '28');
  final _periodLengthController = TextEditingController(text: '5');
  final _notesController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final List<String> _selectedSymptoms = [];

  @override
  void dispose() {
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez d\'abord sélectionner la date de début'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate!.add(const Duration(days: 5)),
      firstDate: _selectedStartDate!,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  void _addSymptom() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Ajouter un symptôme'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Symptôme',
              hintText: 'Ex: Crampes, Ballonnements...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final symptom = controller.text.trim();
                if (symptom.isNotEmpty) {
                  setState(() {
                    _selectedSymptoms.add(symptom);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _savePeriod() {
    if (_selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date de début'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final cycleLength = int.tryParse(_cycleLengthController.text) ?? 28;
    final periodLength = int.tryParse(_periodLengthController.text) ?? 5;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final medicalProvider = Provider.of<MedicalProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? '';

    final periodData = PeriodData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      startDate: _selectedStartDate!,
      endDate: _selectedEndDate,
      cycleLength: cycleLength,
      periodLength: periodLength,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      symptoms: _selectedSymptoms.isEmpty ? null : List.from(_selectedSymptoms),
    );

    medicalProvider.addPeriodData(periodData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Période enregistrée avec succès'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );

    // Réinitialiser le formulaire
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      _selectedSymptoms.clear();
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final medicalProvider = Provider.of<MedicalProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.id ?? '';
    final latestPeriod = medicalProvider.getLatestPeriod(userId);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final user = authProvider.currentUser;
            if (user != null) {
              switch (user.role) {
                case UserRole.admin:
                  context.go('/admin/dashboard');
                  break;
                case UserRole.doctor:
                  context.go('/doctor/dashboard');
                  break;
                case UserRole.patient:
                  context.go('/patient/dashboard');
                  break;
              }
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text('Suivi Menstruel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nouvelle période',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _selectedStartDate == null
                            ? 'Date de début'
                            : 'Début: ${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectStartDate,
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _selectedEndDate == null
                            ? 'Date de fin (optionnel)'
                            : 'Fin: ${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectEndDate,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cycleLengthController,
                            decoration: const InputDecoration(
                              labelText: 'Durée du cycle (jours)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _periodLengthController,
                            decoration: const InputDecoration(
                              labelText: 'Durée des règles (jours)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_selectedSymptoms.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedSymptoms.map((symptom) {
                          return Chip(
                            label: Text(symptom),
                            onDeleted: () {
                              setState(() {
                                _selectedSymptoms.remove(symptom);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addSymptom,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un symptôme'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optionnel)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _savePeriod,
                        child: const Text('Enregistrer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (latestPeriod != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dernière période',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Début: ${latestPeriod.startDate.day}/${latestPeriod.startDate.month}/${latestPeriod.startDate.year}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (latestPeriod.endDate != null)
                        Text(
                          'Fin: ${latestPeriod.endDate!.day}/${latestPeriod.endDate!.month}/${latestPeriod.endDate!.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      Text(
                        'Cycle: ${latestPeriod.cycleLength} jours',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'Règles: ${latestPeriod.periodLength} jours',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (latestPeriod.getNextPeriodDate() != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Prochaine période prévue: ${latestPeriod.getNextPeriodDate()!.day}/${latestPeriod.getNextPeriodDate()!.month}/${latestPeriod.getNextPeriodDate()!.year}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                      if (latestPeriod.notes != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Notes: ${latestPeriod.notes}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if (latestPeriod.symptoms != null &&
                          latestPeriod.symptoms!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: latestPeriod.symptoms!.map((symptom) {
                            return Chip(
                              label: Text(symptom),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

