# 📍 Endroits Favoris

Application Flutter de **gestion d'endroits favoris** réalisée dans le cadre de l'Activité n°2 du cours *Développement Mobile — Niveau Approfondi*.

L'utilisateur peut ajouter un endroit qu'il aime, y associer une **photo prise avec la caméra** de son appareil et enregistrer automatiquement sa **localisation GPS** affichée sur une carte **Google Maps**.

---

## ✨ Fonctionnalités

- ➕ Ajouter un nouvel endroit avec un nom
- 📷 Prendre une photo avec la caméra (`image_picker`)
- 🛰️ Récupérer la position GPS actuelle (`geolocator`)
- 🗺️ Convertir les coordonnées en adresse lisible (`geocoding`)
- 🗺️ Afficher la localisation sur une mini-carte Google Maps
- 📋 Consulter la liste des endroits enregistrés
- 🔍 Voir les détails d'un endroit : photo, adresse et carte plein écran

## 🧱 Architecture du projet

```
lib/
├── main.dart                        # Point d'entrée — ProviderScope (Riverpod)
├── modele/
│   └── endroit.dart                 # Modèle de données Endroit (id UUID, nom, image, GPS)
├── providers/
│   └── endroits_provider.dart       # État global Riverpod v2 (NotifierProvider)
├── widgets/
│   ├── image_prise.dart             # Widget caméra (prise + aperçu de photo)
│   ├── localisation_prise.dart      # Widget GPS (position + mini-carte)
│   └── endroits_list.dart           # Liste déroulante des endroits
└── vue/
    ├── endroits_interface.dart      # Écran principal « Mes endroits préférés »
    ├── ajout_endroit.dart           # Formulaire d'ajout d'un nouvel endroit
    └── endroit_detail.dart          # Page de détails d'un endroit
```

## 📦 Packages utilisés

| Package | Rôle |
|---|---|
| `uuid` | Générer des identifiants uniques pour chaque endroit |
| `flutter_riverpod` | Gestion de l'état global (NotifierProvider v2) |
| `image_picker` | Accès à la caméra pour prendre des photos |
| `google_maps_flutter` | Affichage des cartes Google Maps |
| `geolocator` | Obtention de la position GPS et gestion des permissions |
| `geocoding` | Conversion coordonnées GPS → adresse lisible |

## 🔑 Configuration de la clé API Google Maps

La clé API est configurée dans `android/app/src/main/AndroidManifest.xml`, à l'intérieur de la balise `<application>` :

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="VOTRE_CLE_API_ICI"/>
```

Les permissions de localisation sont déclarées avant la fermeture de `<manifest>` :

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

> ℹ️ Pour obtenir votre propre clé : [console.cloud.google.com](https://console.cloud.google.com) → créer un projet → activer **Maps SDK for Android** → *APIs & Services → Credentials → Create Credentials → API Key*.

## ▶️ Exécution de l'application

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal stable)
- Un appareil Android physique **ou** un émulateur Android (AVD)

### Étapes

```bash
# 1. Vérifier l'environnement
flutter doctor

# 2. Télécharger les dépendances
flutter pub get

# 3. Lancer sur l'appareil/émulateur connecté
flutter run
```

## 🧪 Tests

### Simuler une position GPS sur l'émulateur

Sur un émulateur Android, la position n'est pas réelle. Pour la simuler :

1. Ouvrir les **Extended Controls** de l'émulateur (icône `...` dans la barre d'outils)
2. Aller dans **Location**
3. Saisir une ville dans la barre de recherche puis cliquer sur **Set Location**

Sur un vrai téléphone, la position GPS réelle est utilisée automatiquement.

### Scénarios de test

| N° | Scénario | Résultat attendu |
|---|---|---|
| A | Lancement initial | Écran « Mes endroits préférés » vide avec message d'accueil |
| B | Appui sur `+` | Formulaire « Ajout d'un nouvel endroit » s'ouvre |
| C | Saisie nom + appui sur « Prendre une photo » | La caméra s'ouvre ; après capture, aperçu affiché |
| D | Appui sur « Obtenir ma localisation » | Permission GPS demandée ; mini-carte + adresse affichées |
| E | Appui sur « Enregistrer l'endroit » | Retour à la liste ; le nouvel endroit apparaît en tête |
| F | Répéter B→E puis appui sur un élément de la liste | Page détails : photo, adresse et carte Google Maps |

### Validations testées

- Enregistrement **sans nom** → SnackBar « Veuillez saisir un nom. »
- Enregistrement **sans photo** → SnackBar « Veuillez prendre une photo. »
- Refus des permissions GPS → retour au bouton sans plantage
- Appui sur l'aperçu photo → possibilité de reprendre une photo

---

**Auteur** : Patrick Delva — Session 2, D-CLIC Développement Mobile 2026
