import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../providers/ui_provider.dart';
import '../../models/doctor.dart';
import '../../theme/app_theme.dart';
import '../../widgets/appointment/appointment_booking_dialog.dart';
import '../../widgets/appointment/appointment_card.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final _searchController = TextEditingController();
  List<Doctor> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    final medicalProvider =
        Provider.of<MedicalProvider>(context, listen: false);
    _filteredDoctors = medicalProvider.doctors;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchDoctors(String query) {
    final medicalProvider =
        Provider.of<MedicalProvider>(context, listen: false);
    setState(() {
      _filteredDoctors = medicalProvider.searchDoctors(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final medicalProvider = Provider.of<MedicalProvider>(context);
    final userId = authProvider.currentUser?.id ?? '';
    final appointments = medicalProvider.getAppointmentsByUserId(userId);
    final latestBMI = medicalProvider.getLatestBMI(userId);
    final latestPeriod = medicalProvider.getLatestPeriod(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour, ${authProvider.currentUser?.name ?? ''}'),
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
            // Outils médicaux
            Text(
              'Mes résultats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildResultCard(
                    context,
                    'IMC',
                    latestBMI != null
                        ? latestBMI.bmi.toStringAsFixed(1)
                        : 'Non calculé',
                    Icons.monitor_weight,
                    AppTheme.primaryColor,
                    onTap: () => context.go('/tools/bmi'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildResultCard(
                    context,
                    'Cycle',
                    latestPeriod != null
                        ? 'Suivi actif'
                        : 'Non suivi',
                    Icons.calendar_today,
                    AppTheme.secondaryColor,
                    onTap: () => context.go('/tools/period'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Outils rapides
            Text(
              'Outils médicaux',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildToolCard(
                  context,
                  'Chatbot',
                  Icons.chat,
                  () => context.go('/tools/chatbot'),
                ),
                _buildToolCard(
                  context,
                  'Analyseur',
                  Icons.medical_services,
                  () => context.go('/tools/symptoms'),
                ),
                _buildToolCard(
                  context,
                  'IMC',
                  Icons.monitor_weight,
                  () => context.go('/tools/bmi'),
                ),
                _buildToolCard(
                  context,
                  'Cycle',
                  Icons.calendar_today,
                  () => context.go('/tools/period'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Rendez-vous
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes rendez-vous',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Scroll vers la recherche de médecins
                  },
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (appointments.isEmpty)
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
              ...appointments.map((apt) => AppointmentCard(
                    appointment: apt,
                  )),
            const SizedBox(height: 32),
            // Recherche de médecins
            Text(
              'Rechercher un médecin',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nom ou spécialité...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchDoctors('');
                        },
                      )
                    : null,
              ),
              onChanged: _searchDoctors,
            ),
            const SizedBox(height: 16),
            ..._filteredDoctors.map((doctor) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        doctor.name[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(doctor.name),
                    subtitle: Text(doctor.specialty),
                    trailing: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AppointmentBookingDialog(
                            doctor: doctor,
                          ),
                        );
                      },
                      child: const Text('Réserver'),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    {VoidCallback? onTap}
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

