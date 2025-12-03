import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../providers/ui_provider.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final medicalProvider = Provider.of<MedicalProvider>(context);
    final stats = medicalProvider.getAdminStats();
    final allUsers = MockDataService.getAllUsers();

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - ${authProvider.currentUser?.name ?? ''}'),
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
            // Statistiques
            Text(
              'Statistiques',
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
                _buildStatCard(
                  context,
                  'Utilisateurs',
                  stats['totalUsers'].toString(),
                  Icons.people,
                  AppTheme.primaryColor,
                ),
                _buildStatCard(
                  context,
                  'Médecins',
                  stats['totalDoctors'].toString(),
                  Icons.medical_services,
                  AppTheme.secondaryColor,
                ),
                _buildStatCard(
                  context,
                  'Rendez-vous',
                  stats['totalAppointments'].toString(),
                  Icons.event,
                  AppTheme.warningColor,
                ),
                _buildStatCard(
                  context,
                  'En attente',
                  stats['pendingAppointments'].toString(),
                  Icons.pending,
                  AppTheme.errorColor,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Gestion des utilisateurs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestion des utilisateurs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Ajouter fonctionnalité d'ajout d'utilisateur
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité à venir'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...allUsers.map((user) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(user.role),
                      child: Text(
                        user.name[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        Text(
                          _getRoleText(user.role),
                          style: TextStyle(
                            color: _getRoleColor(user.role),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Modifier'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmer la suppression'),
                              content: Text(
                                'Êtes-vous sûr de vouloir supprimer ${user.name} ?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Annuler'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implémenter la suppression
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Fonctionnalité à venir'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.errorColor,
                                  ),
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppTheme.errorColor;
      case UserRole.doctor:
        return AppTheme.primaryColor;
      case UserRole.patient:
        return AppTheme.secondaryColor;
    }
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.doctor:
        return 'Médecin';
      case UserRole.patient:
        return 'Patient';
    }
  }
}

