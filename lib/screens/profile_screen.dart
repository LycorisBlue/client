import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../widgets/qr_display_widget.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  late AnimationController _saveAnimationController;
  late Animation<double> _saveScaleAnimation;

  UserProfile? currentUser;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserProfile();
  }

  void _initializeAnimations() {
    _saveAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _saveScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadUserProfile() {
    setState(() {
      currentUser = UserService.instance.currentUser;
      _nameController.text = currentUser!.name;
      _emailController.text = currentUser!.email;
      _phoneController.text = currentUser!.phone;
    });

    // Écouter les changements dans les champs
    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final hasChanges = _nameController.text != currentUser!.name ||
        _emailController.text != currentUser!.email ||
        _phoneController.text != currentUser!.phone;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _saveAnimationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Mon Profil'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditing && _hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: Text(
                'Sauvegarder',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: currentUser == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Section Avatar et QR
            _buildHeaderSection(),

            SizedBox(height: 20),

            // Section Informations
            _buildInformationSection(),

            SizedBox(height: 20),

            // Section QR Code
            _buildQRSection(),

            SizedBox(height: 20),

            // Actions
            _buildActionsSection(),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),

          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.grey[300]!, Colors.grey[100]!],
                  ),
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Center(
                  child: Text(
                    currentUser!.initials,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              // Bouton d'édition d'avatar
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _changeAvatar,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Nom et statut
          Text(
            currentUser!.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 4),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Profil Actif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInformationSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                    if (!_isEditing) {
                      // Annuler les modifications
                      _nameController.text = currentUser!.name;
                      _emailController.text = currentUser!.email;
                      _phoneController.text = currentUser!.phone;
                      _hasChanges = false;
                    }
                  });
                },
                icon: Icon(
                  _isEditing ? Icons.close : Icons.edit,
                  color: _isEditing ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // Champ Nom
                _buildFormField(
                  controller: _nameController,
                  label: 'Nom complet',
                  icon: Icons.person,
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est requis';
                    }
                    if (value.trim().length < 2) {
                      return 'Le nom doit contenir au moins 2 caractères';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // Champ Email
                _buildFormField(
                  controller: _emailController,
                  label: 'Adresse email',
                  icon: Icons.email,
                  enabled: _isEditing,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'email est requis';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Format d\'email invalide';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // Champ Téléphone
                _buildFormField(
                  controller: _phoneController,
                  label: 'Numéro de téléphone',
                  icon: Icons.phone,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_PhoneNumberFormatter()],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le téléphone est requis';
                    }
                    if (!RegExp(r'^\+225\s\d{2}\s\d{2}\s\d{2}\s\d{2}$').hasMatch(value)) {
                      return 'Format: +225 XX XX XX XX';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          if (_isEditing && _hasChanges) ...[
            SizedBox(height: 20),
            AnimatedBuilder(
              animation: _saveScaleAnimation,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'Sauvegarder les modifications',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              builder: (context, child) {
                return Transform.scale(
                  scale: _saveScaleAnimation.value,
                  child: child,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQRSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Mon Code QR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              TextButton.icon(
                onPressed: _regenerateQRCode,
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Régénérer'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Center(
            child: QRDisplayWidget(
              qrData: currentUser!.qrCode,
              userName: currentUser!.name,
              size: 180,
            ),
          ),

          SizedBox(height: 12),

          Text(
            'ID: ${currentUser!.qrCode}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Bouton de réinitialisation
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showResetDialog,
              icon: Icon(Icons.refresh, color: Colors.orange),
              label: Text(
                'Réinitialiser le profil',
                style: TextStyle(color: Colors.orange),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.orange),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black87, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[50],
      ),
    );
  }

  // Actions
  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    _saveAnimationController.forward().then((_) {
      _saveAnimationController.reverse();
    });

    final success = await UserService.instance.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: UserService.instance.formatPhoneNumber(_phoneController.text.trim()),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      setState(() {
        currentUser = UserService.instance.currentUser;
        _isEditing = false;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Retourner avec succès
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _regenerateQRCode() async {
    final success = await UserService.instance.regenerateQRCode();
    if (success) {
      setState(() {
        currentUser = UserService.instance.currentUser;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code QR régénéré avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _changeAvatar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fonctionnalité à venir : modification d\'avatar'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Réinitialiser le profil'),
        content: Text(
          'Êtes-vous sûr de vouloir réinitialiser votre profil ? '
              'Cette action supprimera toutes vos données personnelles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await UserService.instance.resetProfile();
              _loadUserProfile();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profil réinitialisé'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text('Réinitialiser', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Formatter pour le numéro de téléphone
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.length <= 4) {
      return newValue;
    }

    // Format automatique : +225 XX XX XX XX
    String formatted = text.replaceAll(RegExp(r'[^\d+]'), '');

    if (!formatted.startsWith('+225')) {
      if (formatted.startsWith('0')) {
        formatted = '+225${formatted.substring(1)}';
      } else if (formatted.startsWith('225')) {
        formatted = '+$formatted';
      } else if (!formatted.startsWith('+')) {
        formatted = '+225$formatted';
      }
    }

    if (formatted.length > 4) {
      String result = formatted.substring(0, 4);
      if (formatted.length > 6) result += ' ${formatted.substring(4, 6)}';
      if (formatted.length > 8) result += ' ${formatted.substring(6, 8)}';
      if (formatted.length > 10) result += ' ${formatted.substring(8, 10)}';
      if (formatted.length > 12) result += ' ${formatted.substring(10, 12)}';

      return TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}