import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../providers/ui_provider.dart';
import '../../services/gemini_service.dart';
import '../../models/appointment.dart';
import '../../theme/app_theme.dart';
import '../../widgets/appointment/appointment_card.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final _quickAdviceController = TextEditingController();
  bool _isLoadingAdvice = false;
  String? _quickAdviceResult;

  @override
  void dispose() {
    _quickAdviceController.dispose();
    super.dispose();
  }

  Future<void> _getQuickAdvice() async {
    final query = _quickAdviceController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoadingAdvice = true;
      _quickAdviceResult = null;
    });

    final result = await GeminiService.getQuickAdvice(query: query);

    setState(() {
      _quickAdviceResult = result;
      _isLoadingAdvice = false;
    });
  }

  Future<void> _updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus newStatus,
  ) async {
    final medicalProvider =
        Provider.of<MedicalProvider>(context, listen: false);
    await medicalProvider.updateAppointmentStatus(appointmentId, newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == AppointmentStatus.accepted
                ? 'Rendez-vous accepté'
                : newStatus == AppointmentStatus.rejected
                    ? 'Rendez-vous refusé'
                    : 'Rendez-vous terminé',
          ),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final medicalProvider = Provider.of<MedicalProvider>(context);
    final userId = authProvider.currentUser?.id ?? '';
    final pendingAppointments =
        medicalProvider.getPendingAppointmentsForDoctor(userId);
    final allAppointments = medicalProvider.getAppointmentsByUserId(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${authProvider.currentUser?.name ?? ''}'),
        actions: [
          Consumer<UIProvider>(
            builder: (context, uiProvider, _) => IconButton(
              icon: Icon(
                uiProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () => uiProvider.toggleTheme(),
              tooltip: 'Basculer le thème',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                context.go('/auth');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avis Rapide IA
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Avis Rapide',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _quickAdviceController,
                      decoration: InputDecoration(
                        hintText: 'Posez une question médicale...',
                        suffixIcon: IconButton(
                          icon: _isLoadingAdvice
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          onPressed: _isLoadingAdvice ? null : _getQuickAdvice,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    if (_quickAdviceResult != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _quickAdviceResult!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Demandes en attente
            Text(
              'Demandes en attente (${pendingAppointments.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (pendingAppointments.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune demande en attente',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...pendingAppointments.map((apt) => AppointmentCard(
                    appointment: apt,
                    actions: [
                      TextButton(
                        onPressed: () => _updateAppointmentStatus(
                          apt.id,
                          AppointmentStatus.rejected,
                        ),
                        child: const Text('Refuser'),
                      ),
                      ElevatedButton(
                        onPressed: () => _updateAppointmentStatus(
                          apt.id,
                          AppointmentStatus.accepted,
                        ),
                        child: const Text('Accepter'),
                      ),
                    ],
                  )),
            const SizedBox(height: 32),
            // Tous les rendez-vous
            Text(
              'Tous mes rendez-vous',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (allAppointments.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun rendez-vous',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...allAppointments.map((apt) {
                final canComplete = apt.status == AppointmentStatus.accepted;
                return AppointmentCard(
                  appointment: apt,
                  actions: canComplete
                      ? [
                          ElevatedButton(
                            onPressed: () => _updateAppointmentStatus(
                              apt.id,
                              AppointmentStatus.completed,
                            ),
                            child: const Text('Marquer terminé'),
                          ),
                        ]
                      : null,
                );
              }),
          ],
        ),
      ),
    );
  }
}

