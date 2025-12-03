import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../models/user.dart';
import '../../services/gemini_service.dart';
import '../../models/medical_data.dart';
import '../../theme/app_theme.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool _isLoading = false;
  BMIData? _lastResult;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _calculateBMI() async {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || height == null || weight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer des valeurs valides'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Convertir la taille en mètres si elle est en cm
    final heightInMeters = height > 3 ? height / 100 : height;

    setState(() {
      _isLoading = true;
    });

    final bmi = BMIData.calculateBMI(weight, heightInMeters);

    // Obtenir l'interprétation IA
    final aiResult = await GeminiService.interpretBMI(
      bmi: bmi,
      weight: weight,
      height: heightInMeters,
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final medicalProvider = Provider.of<MedicalProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? '';

    final bmiData = BMIData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      weight: weight,
      height: heightInMeters,
      bmi: bmi,
      date: DateTime.now(),
      aiInterpretation: aiResult['interpretation'],
      aiAdvice: aiResult['advice'],
    );

    medicalProvider.addBMIData(bmiData);

    setState(() {
      _lastResult = bmiData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final medicalProvider = Provider.of<MedicalProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.id ?? '';
    final latestBMI = medicalProvider.getLatestBMI(userId) ?? _lastResult;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final currentAuthProvider = Provider.of<AuthProvider>(context, listen: false);
            final user = currentAuthProvider.currentUser;
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
        title: const Text('Calculateur IMC'),
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
                  children: [
                    TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Poids (kg)',
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Taille (m ou cm)',
                        prefixIcon: Icon(Icons.height),
                        helperText: 'Exemple: 1.75 ou 175',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _calculateBMI,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Calculer l\'IMC'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (latestBMI != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Résultat',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                latestBMI.bmi.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              Text(
                                BMIData.getBMICategory(latestBMI.bmi),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (latestBMI.aiInterpretation != null) ...[
                        Text(
                          'Interprétation',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          latestBMI.aiInterpretation!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (latestBMI.aiAdvice != null) ...[
                        Text(
                          'Conseils',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          latestBMI.aiAdvice!,
                          style: Theme.of(context).textTheme.bodyMedium,
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

