import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../models/user.dart';
import '../../services/gemini_service.dart';
import '../../models/medical_data.dart';
import '../../theme/app_theme.dart';

class SymptomAnalyzer extends StatefulWidget {
  const SymptomAnalyzer({super.key});

  @override
  State<SymptomAnalyzer> createState() => _SymptomAnalyzerState();
}

class _SymptomAnalyzerState extends State<SymptomAnalyzer> {
  final _symptomController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final List<String> _selectedSymptoms = [];
  bool _isLoading = false;
  SymptomAnalysis? _lastAnalysis;

  @override
  void dispose() {
    _symptomController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _addSymptom() {
    final symptom = _symptomController.text.trim();
    if (symptom.isNotEmpty && !_selectedSymptoms.contains(symptom)) {
      setState(() {
        _selectedSymptoms.add(symptom);
        _symptomController.clear();
      });
    }
  }

  void _removeSymptom(String symptom) {
    setState(() {
      _selectedSymptoms.remove(symptom);
    });
  }

  Future<void> _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins un symptôme'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final additionalInfo = _additionalInfoController.text.trim();

    final result = await GeminiService.analyzeSymptoms(
      symptoms: _selectedSymptoms,
      additionalInfo: additionalInfo.isEmpty ? null : additionalInfo,
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final medicalProvider = Provider.of<MedicalProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? '';

    final analysis = SymptomAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      symptoms: List.from(_selectedSymptoms),
      severity: result['severity'] ?? 'medium',
      possibleCauses: result['possibleCauses'],
      immediateAdvice: result['immediateAdvice'],
      date: DateTime.now(),
    );

    medicalProvider.addSymptomAnalysis(analysis);

    setState(() {
      _lastAnalysis = analysis;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        title: const Text('Analyseur de Symptômes'),
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
                      'Décrivez vos symptômes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _symptomController,
                            decoration: const InputDecoration(
                              labelText: 'Ajouter un symptôme',
                              hintText: 'Ex: Maux de tête, Fièvre...',
                            ),
                            onSubmitted: (_) => _addSymptom(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addSymptom,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                    if (_selectedSymptoms.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedSymptoms.map((symptom) {
                          return Chip(
                            label: Text(symptom),
                            onDeleted: () => _removeSymptom(symptom),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: _additionalInfoController,
                      decoration: const InputDecoration(
                        labelText: 'Informations supplémentaires (optionnel)',
                        hintText: 'Durée, intensité, contexte...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _analyzeSymptoms,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Analyser les symptômes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_lastAnalysis != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.getSeverityColor(
                                _lastAnalysis!.severity,
                                isDark,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Niveau: ${_lastAnalysis!.severity.toUpperCase()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getSeverityColor(
                                  _lastAnalysis!.severity,
                                  isDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_lastAnalysis!.possibleCauses != null) ...[
                        Text(
                          'Causes potentielles',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastAnalysis!.possibleCauses!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_lastAnalysis!.immediateAdvice != null) ...[
                        Text(
                          'Conseils immédiats',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastAnalysis!.immediateAdvice!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if (_lastAnalysis!.severity == 'emergency' ||
                          _lastAnalysis!.severity == 'high') ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.errorColor,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: AppTheme.errorColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Consultez immédiatement un médecin ou appelez les urgences (15)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

