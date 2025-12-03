import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;

  // Contrôleurs pour le formulaire de connexion
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Contrôleurs pour le formulaire d'inscription
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _registerAddressController = TextEditingController();
  UserRole _selectedRole = UserRole.patient;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // S'assurer que l'animation commence à 0 (connexion)
    _flipController.value = 0.0;
  }

  @override
  void dispose() {
    _flipController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerPhoneController.dispose();
    _registerAddressController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    if (_flipController.value < 0.5) {
      // Passer de connexion à inscription
      _flipController.forward();
    } else {
      // Passer d'inscription à connexion
      _flipController.reverse();
    }
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Effacer les erreurs précédentes
    authProvider.clearError();
    
    final success = await authProvider.login(
      _loginEmailController.text.trim(),
      _loginPasswordController.text.trim(),
    );

    if (success && mounted) {
      final user = authProvider.currentUser;
      if (user != null) {
        // Effacer le message d'erreur en cas de succès
        authProvider.clearError();
        
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
      }
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      email: _registerEmailController.text.trim(),
      password: _registerPasswordController.text,
      name: _registerNameController.text.trim(),
      role: _selectedRole,
      phone: _registerPhoneController.text.trim().isEmpty
          ? null
          : _registerPhoneController.text.trim(),
      address: _registerAddressController.text.trim().isEmpty
          ? null
          : _registerAddressController.text.trim(),
    );

    if (success && mounted) {
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
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erreur d\'inscription'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.1),
                  ]
                : [
                    AppTheme.primaryColor.withOpacity(0.05),
                    AppTheme.secondaryColor.withOpacity(0.05),
                  ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedBuilder(
              animation: _flipController,
              builder: (context, child) {
                final angle = _flipController.value * 3.14159; // π radians
                // Déterminer quel formulaire afficher selon l'angle
                // À 0° (0.0) = connexion, à 180° (1.0) = inscription
                final showRegister = _flipController.value >= 0.5;
                
                // Masquer le formulaire pendant la rotation (à 90°)
                final opacity = (angle < 1.57 || angle > 1.57) ? 1.0 : 0.0;

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: Opacity(
                    opacity: opacity,
                    child: showRegister
                        ? Transform(
                            alignment: Alignment.center,
                            // Utiliser scale négatif sur X pour corriger l'inversion miroir
                            transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                            child: _buildRegisterForm(authProvider, isDark),
                          )
                        : _buildLoginForm(authProvider, isDark),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medical_services,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Connexion',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _loginEmailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _loginPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : _handleLogin,
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Se connecter'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _toggleMode,
              child: const Text('Pas encore de compte ? S\'inscrire'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildRegisterForm(AuthProvider authProvider, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Inscription',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _registerNameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _registerEmailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _registerPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Rôle',
                prefixIcon: Icon(Icons.work),
              ),
              items: const [
                DropdownMenuItem(
                  value: UserRole.patient,
                  child: Text('Patient'),
                ),
                DropdownMenuItem(
                  value: UserRole.doctor,
                  child: Text('Médecin'),
                ),
                DropdownMenuItem(
                  value: UserRole.admin,
                  child: Text('Administrateur'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _registerPhoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone (optionnel)',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _registerAddressController,
              decoration: const InputDecoration(
                labelText: 'Adresse (optionnel)',
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : _handleRegister,
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('S\'inscrire'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _toggleMode,
              child: const Text('Déjà un compte ? Se connecter'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY();
  }
}

