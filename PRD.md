# Medigeni - Application Web Progressive de Santé Numérique

## 1. Vue d'Ensemble du Projet

Medigeni est une Application Web Progressive (PWA) moderne de santé numérique qui combine des outils médicaux assistés par intelligence artificielle avec une plateforme de mise en relation entre patients et professionnels de santé. L'application offre une expérience utilisateur fluide et intuitive pour la gestion de la santé personnelle et la coordination des soins médicaux.

## 2. Objectifs du Projet

- **Objectif Principal :** Fournir une solution complète de santé numérique accessible via navigateur web avec une expérience utilisateur optimale.
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

- **Frontend Framework :** React avec TypeScript
- **Styling :** Tailwind CSS
- **Intelligence Artificielle :** Google Gemini API
- **Type de Déploiement :** Progressive Web App (PWA)

### 4.2. Structure du Projet

```
src/
├── components/       # Composants réutilisables
│   ├── Layout       # Structure de page
│   ├── Navbar       # Navigation
│   ├── Modals       # Fenêtres contextuelles
│   └── Cards        # Éléments de carte
├── pages/           # Vues principales (routes)
│   ├── Home
│   ├── Dashboard
│   └── Tools
├── services/        # Logique métier externe
│   ├── API Gemini
│   └── Mock Data
├── context/         # Gestion d'état global
│   ├── AuthContext
│   ├── MedicalContext
│   └── UIContext
└── types.ts         # Définitions TypeScript
```

### 4.3. Gestion de l'État Global

L'application utilise l'API Context de React divisée en trois contextes spécialisés :

- **AuthContext :** Gestion de l'authentification et des sessions
- **MedicalContext :** Base de données temps réel côté client pour les données de santé et rendez-vous
- **UIContext :** Contrôle de l'interface utilisateur et des modals

### 4.4. Architecture Modulaire

- Structure feature-based pour une maintenance facilitée
- Séparation claire des responsabilités
- Composants réutilisables et découplés
- Services centralisés pour les appels externes

## 5. Expérience Utilisateur (UX)

### 5.1. Design Responsive

- Adaptation automatique mobile/tablette/desktop
- Utilisation des classes utilitaires Tailwind
- Grille flexible et points de rupture optimisés

### 5.2. Mode Sombre

- Implémentation native du dark mode
- Basculement fluide entre thèmes
- Classes conditionnelles Tailwind

### 5.3. Feedback Visuel

- Indicateurs de chargement pendant les opérations IA
- Animations et transitions fluides
- États de validation et messages d'erreur clairs

## 6. Intégration de l'Intelligence Artificielle

### 6.1. Service Gemini Centralisé

Le fichier `services/geminiService.ts` gère toutes les interactions avec l'API Google Gemini :

- **Instructions Système :** Prompts spécifiques pour chaque fonctionnalité
- **Gestion de l'Historique :** Conservation du contexte conversationnel
- **Réponses Structurées :** Formatage cohérent des résultats IA
- **Gestion des Erreurs :** Fallbacks et messages appropriés

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

- Node.js (version recommandée : 18+)
- npm ou yarn
- Clé API Google Gemini
- Navigateur moderne compatible PWA

## 9. Cas d'Usage Principaux

1. **Patient recherchant des informations médicales :** Utilise le chatbot et l'analyseur de symptômes
2. **Patient prenant rendez-vous :** Parcourt la liste des médecins, réserve un créneau
3. **Médecin gérant sa patientèle :** Consulte les demandes, accepte/refuse les rendez-vous
4. **Médecin utilisant l'IA :** Vérifie rapidement une information médicale via "Avis Rapide"
5. **Administrateur supervisant la plateforme :** Gère les utilisateurs et consulte les statistiques

## 10. Points Techniques Notables

- **Workflow de Rendez-vous Complexe :** Interaction sophistiquée entre plusieurs contextes
- **Authentification Dynamique :** Inscription avec ajout temps réel au système
- **Synchronisation d'État :** Mise à jour instantanée entre composants via contextes
- **Architecture Sans Backend :** Démonstration complète avec services simulés

## 11. Perspectives d'Évolution

Cette architecture modulaire facilite l'ajout de :

- Persistance des données avec base de données réelle
- Système de notifications en temps réel
- Intégration de paiements pour consultations
- Téléconsultation vidéo
- Dossier médical électronique complet
- Tests unitaires et d'intégration

---

**Note :** Ce projet démontre une architecture professionnelle complète, prête pour la production après intégration d'un backend réel. Le code est structuré, typé, et documenté pour faciliter la maintenance et l'évolution future.
