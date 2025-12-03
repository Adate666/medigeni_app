# Medigeni - Application Mobile de Santé Numérique

<img width="492" height="757" alt="medi0" src="https://github.com/user-attachments/assets/5f9284e1-68ab-45f2-8203-c02bec1c0078" />
<img width="499" height="763" alt="medi_admin_dash" src="https://github.com/user-attachments/assets/3b032f52-907b-4698-938d-2ae1e725d9e6" />
<img width="498" height="766" alt="medi_dashboard_patient" src="https://github.com/user-attachments/assets/0a9cf18a-e06d-410c-b04b-ae10575b0016" />
<img width="499" height="761" alt="medi_dashboard_medecin" src="https://github.com/user-attachments/assets/ac6ebc4a-712f-471c-ae75-bc354409db0a" />


## 1. Vue d'Ensemble du Projet

Medigeni est une application mobile native moderne de santé numérique qui combine des outils médicaux assistés par intelligence artificielle avec une plateforme de mise en relation entre patients et professionnels de santé. L'application offre une expérience utilisateur fluide et intuitive pour la gestion de la santé personnelle et la coordination des soins médicaux sur iOS et Android.

## 2. Objectifs du Projet

- **Objectif Principal :** Fournir une solution mobile complète de santé numérique pour iOS et Android avec une expérience utilisateur optimale.
- **Objectifs Secondaires :**
  - Démontrer l'intégration d'intelligence artificielle dans le domaine médical
  - Faciliter la communication patient-médecin via un système de rendez-vous
  - Offrir des outils de santé personnalisés et interactifs
  - Maintenir une architecture modulaire et évolutive

## 3. Fonctionnalités Principales

### 3.1. Outils Médicaux Assistés par IA

- **Chatbot Médical Intelligent**
  - Assistant conversationnel empathique
  - Historique de conversation persistant
  - Disclaimers médicaux intégrés
- **Calculateur IMC Avancé**
  - Calcul mathématique de l'Indice de Masse Corporelle
  - Interprétation textuelle générée par IA
  - Conseils personnalisés basés sur les résultats
- **Analyseur de Symptômes**
  - Système de triage intelligent
  - Évaluation du niveau d'urgence
  - Causes potentielles et conseils immédiats
- **Suivi Menstruel**
  - Gestion du cycle menstruel
  - Synchronisation avec le tableau de bord personnel

### 3.2. Plateforme de Mise en Relation

- **Système de Prise de Rendez-vous**
  - Workflow complet de réservation
  - Gestion des statuts (en attente, accepté, terminé)
  - Communication des coordonnées patient-médecin
- **Gestion de Patientèle**
  - Vue des demandes en attente pour les médecins
  - Actions de gestion (accepter, refuser, terminer)
  - Accès aux informations de contact des patients

### 3.3. Système d'Authentification Multi-rôles

- **Gestion des Utilisateurs**
  - Inscription et connexion sécurisées
  - Trois niveaux de rôles : Admin, Médecin, Patient
  - Redirection automatique selon le rôle
- **Interface d'Authentification**
  - Modal unique avec effet "Flip 3D"
  - Bascule fluide entre connexion et inscription
  - Persistance de session

### 3.4. Tableaux de Bord Personnalisés

- **Dashboard Patient**
  - Affichage des résultats d'outils (IMC, cycle menstruel)
  - Liste des rendez-vous avec codes couleurs
  - Moteur de recherche de médecins (filtrage par nom/spécialité)
- **Dashboard Médecin**
  - Vue centralisée des demandes de rendez-vous
  - Outil "Avis Rapide" pour vérifications médicales via IA
  - Gestion complète des rendez-vous patients
- **Dashboard Administrateur**
  - Statistiques globales de la plateforme
  - Gestion CRUD des utilisateurs
  - Vue d'ensemble du système

## 4. Architecture Technique

### 4.1. Stack Technologique

- **Framework Mobile :** Flutter (Dart)
- **Styling :** Material Design & Cupertino Widgets
- **Intelligence Artificielle :** Google Gemini API
- **Plateformes :** iOS et Android

### 4.2. Structure du Projet

```
lib/
├── main.dart                # Point d'entrée de l'application
├── app.dart                 # Configuration MaterialApp
├── src/
    ├── features/            # Structure basée sur les fonctionnalités
    │   ├── authentication/
    │   │   ├── data/        # Modèles et providers
    │   │   ├── domain/      # Logique métier
    │   │   └── presentation/ # Screens et widgets
    │   ├── home/
    │   ├── tools/
    │   └── dashboard/
    ├── common/              # Widgets partagés
    │   ├── widgets/         # Composants réutilisables
    │   ├── constants/       # Constantes de l'app
    │   └── utils/           # Utilitaires
    ├── services/            # Services externes
    │   ├── gemini_service.dart
    │   └── mock_data.dart
    ├── providers/           # Gestion d'état (Provider/Riverpod)
    │   ├── auth_provider.dart
    │   ├── medical_provider.dart
    │   └── ui_provider.dart
    └── models/              # Modèles de données
        └── types.dart
```

### 4.3. Gestion de l'État Global

L'application utilise un système de gestion d'état (Provider/Riverpod) divisé en trois providers spécialisés :

- **AuthProvider :** Gestion de l'authentification et des sessions
- **MedicalProvider :** Base de données temps réel côté client pour les données de santé et rendez-vous
- **UIProvider :** Contrôle de l'interface utilisateur et des dialogues/modals

### 4.4. Architecture Modulaire

- Structure feature-based pour une maintenance facilitée
- Séparation claire des responsabilités
- Composants réutilisables et découplés
- Services centralisés pour les appels externes

## 5. Expérience Utilisateur (UX)

### 5.1. Design Responsive

- Adaptation automatique mobile/tablette
- Utilisation des widgets Flutter responsifs (MediaQuery, LayoutBuilder)
- Design adaptatif selon la taille d'écran
- Support des orientations portrait et paysage

### 5.2. Mode Sombre

- Implémentation native du ThemeMode (light/dark)
- Basculement fluide entre thèmes via ThemeData
- Support des préférences système

### 5.3. Feedback Visuel

- Indicateurs de chargement (CircularProgressIndicator) pendant les opérations IA
- Animations et transitions fluides (Hero, AnimatedContainer)
- SnackBars et Dialogs pour les états de validation et messages d'erreur
- Feedback haptique pour les interactions importantes

## 6. Intégration de l'Intelligence Artificielle

### 6.1. Service Gemini Centralisé

Le fichier `services/gemini_service.dart` gère toutes les interactions avec l'API Google Gemini :

- **Instructions Système :** Prompts spécifiques pour chaque fonctionnalité
- **Gestion de l'Historique :** Conservation du contexte conversationnel
- **Réponses Structurées :** Formatage cohérent des résultats IA
- **Gestion des Erreurs :** Fallbacks et messages appropriés
- **Appels Asynchrones :** Utilisation de Future et async/await

### 6.2. Cas d'Usage de l'IA

- Génération de conseils santé personnalisés
- Analyse et interprétation de données médicales
- Assistance médicale conversationnelle
- Vérification de posologies et interactions médicamenteuses

## 7. Simulation Backend

### 7.1. Données Mock

- Utilisateurs pré-définis avec différents rôles
- Liste de médecins avec spécialités
- Gestion en mémoire des rendez-vous

### 7.2. Évolutivité Backend

L'architecture est prête pour une intégration backend réelle :

- Remplacement simple des fonctions de services
- Compatibilité avec Firebase, Supabase, ou API REST
- Structure de données déjà typée et normalisée

## 8. Prérequis et Installation

- Flutter SDK (version recommandée : 3.16+)
- Dart SDK
- Android Studio / Xcode (pour le développement iOS)
- Clé API Google Gemini
- Émulateurs/simulateurs iOS et Android ou appareils physiques

## 9. Cas d'Usage Principaux

1. **Patient recherchant des informations médicales :** Utilise le chatbot et l'analyseur de symptômes
2. **Patient prenant rendez-vous :** Parcourt la liste des médecins, réserve un créneau
3. **Médecin gérant sa patientèle :** Consulte les demandes, accepte/refuse les rendez-vous
4. **Médecin utilisant l'IA :** Vérifie rapidement une information médicale via "Avis Rapide"
5. **Administrateur supervisant la plateforme :** Gère les utilisateurs et consulte les statistiques

## 10. Points Techniques Notables

- **Workflow de Rendez-vous Complexe :** Interaction sophistiquée entre plusieurs providers
- **Authentification Dynamique :** Inscription avec ajout temps réel au système
- **Synchronisation d'État :** Mise à jour instantanée entre écrans via providers
- **Architecture Sans Backend :** Démonstration complète avec services simulés
- **Navigation Déclarative :** Utilisation de Navigator 2.0 ou Go Router

## 11. Perspectives d'Évolution

Cette architecture modulaire facilite l'ajout de :

- Persistance des données avec base de données réelle (SQLite, Hive, Firebase)
- Système de notifications push (Firebase Cloud Messaging)
- Intégration de paiements pour consultations (Stripe, PayPal)
- Téléconsultation vidéo (Agora, WebRTC)
- Dossier médical électronique complet
- Tests unitaires, widgets et d'intégration
- Localisation multilingue (i18n)
- Mode hors ligne avec synchronisation

---

# medigeni_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

**Note :** Ce projet démontre une architecture professionnelle complète, prête pour la production après intégration d'un backend réel. Le code est structuré, typé, et documenté pour faciliter la maintenance et l'évolution future.
