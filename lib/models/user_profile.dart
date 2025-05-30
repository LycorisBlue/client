class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String qrCode;
  final String? avatarPath;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.qrCode,
    this.avatarPath,
  });

  // Constructeur pour créer un profil par défaut
  factory UserProfile.defaultProfile() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return UserProfile(
      id: timestamp,
      name: 'Utilisateur',
      email: 'user@example.com',
      phone: '+225 00 00 00 00',
      qrCode: 'QR_USER_$timestamp',
    );
  }

  // Méthode pour copier avec modifications
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? qrCode,
    String? avatarPath,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      qrCode: qrCode ?? this.qrCode,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  // Conversion vers Map pour la sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'qrCode': qrCode,
      'avatarPath': avatarPath,
    };
  }

  // Création depuis Map
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      qrCode: json['qrCode'] ?? '',
      avatarPath: json['avatarPath'],
    );
  }

  // Validation des données
  bool get isValid {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        email.contains('@') &&
        phone.isNotEmpty;
  }

  // Initiales pour l'avatar
  String get initials {
    if (name.isEmpty) return 'U';
    final names = name.split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    }
    return (names[0].substring(0, 1) + names[1].substring(0, 1)).toUpperCase();
  }
}