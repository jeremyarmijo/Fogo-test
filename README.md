# Bluetooth Scanner

Une application Flutter qui permet de scanner et lister les appareils Bluetooth à proximité, développée selon les bonnes pratiques avec le pattern BLoC.

## 🎯 Fonctionnalités

- **Scan Bluetooth** : Détection automatique des appareils Bluetooth environnants
- **Affichage en temps réel** : Mise à jour live de la liste des appareils détectés
- **Indicateurs de signal** : Visualisation de la force du signal RSSI avec couleurs et icônes
- **Gestion des permissions** : Demande automatique des permissions nécessaires
- **État Bluetooth** : Détection et gestion de l'état Bluetooth de l'appareil
- **Interface intuitive** : Design Material 3 avec indicateurs visuels clairs

## 🏗️ Architecture

Le projet suit l'architecture BLoC (Business Logic Component) pour une séparation claire des responsabilités :

```
lib/
├── bloc/                   # Logique métier avec BLoC
│   ├── bluetooth_bloc.dart
│   ├── bluetooth_event.dart
│   └── bluetooth_state.dart
├── models/                 # Modèles de données
│   └── bluetooth_device_model.dart
├── screens/                # Écrans de l'application
│   └── bluetooth_scan_screen.dart
├── services/               # Services (API Bluetooth)
│   └── bluetooth_service.dart
├── widgets/                # Composants réutilisables
│   └── bluetooth_device_item.dart
└── main.dart              # Point d'entrée
```

## 📦 Dépendances

- **flutter_blue_plus** (^1.35.5) : API Bluetooth avancée
- **flutter_bloc** (^9.1.1) : Gestion d'état avec BLoC pattern
- **permission_handler** (^11.3.1) : Gestion des permissions système
- **equatable** (^2.0.5) : Comparaison d'objets pour BLoC

## 🚀 Installation et lancement

1. **Cloner le projet** :
   ```bash
   git clone <url-du-repo>
   cd bluetooth_scanner
   ```

2. **Installer les dépendances** :
   ```bash
   flutter pub get
   ```

3. **Lancer l'application** :
   ```bash
   # Sur émulateur/appareil Android (recommandé)
   flutter run
   
   # Sur navigateur web (uniquement pour tester l'UI - Bluetooth non supporté)
   flutter run -d chrome
   ```

## ⚠️ **Important - Support des plateformes**

- ✅ **Android/iOS** : Fonctionnalité Bluetooth complète
- ✅ **Desktop (Linux/Windows/macOS)** : Support Bluetooth natif
- ❌ **Web** : Affiche "Bluetooth Not Supported" (comportement normal)

> **Note** : Pour tester réellement la fonctionnalité Bluetooth, utilisez un appareil physique ou un émulateur Android/iOS.

## 📱 Permissions requises

### Android
- `BLUETOOTH` et `BLUETOOTH_ADMIN` (Android < 12)
- `BLUETOOTH_SCAN` et `BLUETOOTH_CONNECT` (Android 12+)
- `ACCESS_FINE_LOCATION` (requis pour le scan Bluetooth)

### iOS
- `NSBluetoothAlwaysUsageDescription` dans Info.plist

## 🎨 Interface utilisateur

L'application présente :

- **AppBar** avec bouton de scan/arrêt
- **Barre de statut** indiquant l'état du scan et le nombre d'appareils
- **Liste des appareils** avec :
  - Nom de l'appareil (ou "Unknown Device")
  - ID unique de l'appareil
  - Valeur RSSI en dBm
  - Indicateur visuel de la force du signal
- **FAB** pour démarrer/arrêter le scan
- **Écrans d'erreur** informatifs pour les cas d'échec

## 🔄 États de l'application

- **Initial** : État de démarrage
- **Loading** : Initialisation en cours
- **Ready** : Prêt à scanner, affichage des appareils
- **Error** : Erreur avec message explicatif
- **NotSupported** : Bluetooth non supporté
- **PermissionDenied** : Permissions refusées
- **Disabled** : Bluetooth désactivé

## 🧪 Tests

Structure préparée pour les tests unitaires du BLoC :

```bash
flutter test
```

## 📋 Bonnes pratiques implémentées

- ✅ **Architecture BLoC** : Séparation logique métier/UI
- ✅ **Immutabilité** : États immutables avec copyWith
- ✅ **Gestion d'erreurs** : Catch et affichage approprié des erreurs
- ✅ **Ressources** : Dispose automatique des streams et subscriptions
- ✅ **Performance** : Évitement des doublons dans la liste d'appareils
- ✅ **UX** : Indicateurs visuels et messages informatifs
- ✅ **Code propre** : Nommage clair et organisation modulaire

## 🚧 Développement

Le projet est configuré avec :
- Analyse statique Flutter/Dart
- Support multi-plateforme (Android/iOS principalement)
- Hot reload pour le développement rapide

## 📄 Licence

Ce projet est un test technique développé avec Flutter et les bonnes pratiques de développement mobile.
