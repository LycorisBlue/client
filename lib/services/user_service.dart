import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserService {
  static const String _userProfileKey = 'user_profile';
  static UserService? _instance;
  UserProfile? _currentUser;

  // Singleton pattern
  static UserService get instance {
    _instance ??= UserService._();
    return _instance!;
  }

  UserService._();

  // Getter pour l'utilisateur actuel
  UserProfile get currentUser {
    _currentUser ??= UserProfile.defaultProfile();
    return _currentUser!;
  }

  // Initialiser le service au démarrage de l'app
  Future<void> initialize() async {
    await _loadUserProfile();
  }

  // Charger le profil utilisateur depuis le stockage local
  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userProfileKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = UserProfile.fromJson(userMap);
      } else {
        // Premier lancement - créer un profil par défaut
        _currentUser = UserProfile.defaultProfile();
        await _saveUserProfile();
      }
    } catch (e) {
      // En cas d'erreur, utiliser le profil par défaut
      _currentUser = UserProfile.defaultProfile();
      await _saveUserProfile();
    }
  }

  // Sauvegarder le profil utilisateur
  Future<bool> _saveUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(_currentUser!.toJson());
      return await prefs.setString(_userProfileKey, userJson);
    } catch (e) {
      return false;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatarPath,
  }) async {
    try {
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email,
        phone: phone,
        avatarPath: avatarPath,
      );

      return await _saveUserProfile();
    } catch (e) {
      return false;
    }
  }

  // Régénérer le QR code
  Future<bool> regenerateQRCode() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      _currentUser = _currentUser!.copyWith(
        qrCode: 'QR_USER_$timestamp',
      );

      return await _saveUserProfile();
    } catch (e) {
      return false;
    }
  }

  // Valider les données utilisateur
  bool validateUserData({
    required String name,
    required String email,
    required String phone,
  }) {
    // Validation du nom
    if (name.trim().isEmpty || name.trim().length < 2) {
      return false;
    }

    // Validation de l'email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return false;
    }

    // Validation du téléphone (format ivoirien)
    final phoneRegex = RegExp(r'^\+225\s\d{2}\s\d{2}\s\d{2}\s\d{2}$');
    if (!phoneRegex.hasMatch(phone.trim())) {
      return false;
    }

    return true;
  }

  // Formater le numéro de téléphone
  String formatPhoneNumber(String phone) {
    // Supprimer tous les espaces et caractères spéciaux
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Si le numéro commence par 0, le remplacer par +225
    if (cleaned.startsWith('0')) {
      cleaned = '+225${cleaned.substring(1)}';
    }

    // Si le numéro ne commence pas par +225, l'ajouter
    if (!cleaned.startsWith('+225')) {
      cleaned = '+225$cleaned';
    }

    // Formater avec des espaces : +225 XX XX XX XX
    if (cleaned.length == 13) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)} ${cleaned.substring(10, 12)}';
    }

    return cleaned;
  }

  // Réinitialiser le profil (pour les tests ou reset)
  Future<bool> resetProfile() async {
    try {
      _currentUser = UserProfile.defaultProfile();
      return await _saveUserProfile();
    } catch (e) {
      return false;
    }
  }

  // Vérifier si c'est le premier lancement
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(_userProfileKey);
  }
}