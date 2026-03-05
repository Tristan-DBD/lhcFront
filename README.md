# LHC Coaching - Flutter Front-end

Application mobile de coaching sportif pour la gestion des cours collectifs, des programmes d'entraînement, du suivi des paiements et du suivi des athlètes.

## 🚀 Mise en route

### Prérequis
- Flutter SDK (version ^3.10.7)
- Dart SDK
- Un éditeur de code (VS Code ou Android Studio)

### Installation
1. Cloner le dépôt.
2. Installer les dépendances :
   ```bash
   flutter pub get
   ```
3. Créer un fichier `.env` à la racine du projet en vous basant sur `.env.example`.
4. Lancer l'application :
   ```bash
   flutter run
   ```

## ⚙️ Configuration (.env)
L'application nécessite les variables suivantes :
- `API_URL` : URL de votre API REST.
- `SUPABASE_URL` : URL de votre instance Supabase.
- `SUPABASE_ANON_KEY` : Clé anonyme Supabase.

## 🏗️ Architecture
Le projet suit une architecture **Feature-first** (orientée fonctionnalités) pour une meilleure modularité.

### Fonctionnalités Clés
- **Authentification** : Connexion, déconnexion et changement de mot de passe obligatoire.
- **Cours** : Inscription et suivi des cours collectifs.
- **Paiements** : Suivi des paiements annuels (vue athlète et admin).
- **Programmes** : Consultation des programmes sportifs personnalisés.
- **Profil** : Gestion des informations personnelles et statistiques (Squat, Bench, Deadlift).

### Structure des dossiers
- `lib/features/` : Modules métiers (user, course, profile).
- `lib/services/` : Couche d'accès aux données (API, Auth, Storage).
- `lib/models/` : Modèles de données.
- `lib/widgets/` : Composants UI réutilisables.
- `lib/utils/` : Helpers (Navigation, Responsive).

### Gestion d'état
- Utilisation de **ChangeNotifier** avec le pattern **Controller** pour séparer la logique métier de l'UI (ex: `CourseController`).
- **ListenableBuilder** pour la mise à jour réactive de l'interface.

## 🎨 Design System
L'application supporte le **mode sombre** nativement. Les couleurs et styles sont centralisés dans `lib/constant/app_theme.dart`.

## 📱 Configuration Réseau (Développement)
Pour tester l'application sur un appareil physique sur le même réseau local, assurez-vous que `API_URL` dans votre `.env` pointe vers l'adresse IP locale de votre machine (ex: `http://192.168.1.XX:4000/api`).

## 🛠️ Optimisations Recommendations
- **API Cache** : Éviter les appels redondants en mettant en cache les données utilisateur.
- **Batching** : Privilégier les requêtes groupées pour les listes (ex: participants d'un cours) afin d'éviter le problème de "N+1 queries".
