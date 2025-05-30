import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../widgets/qr_display_widget.dart';
import '../widgets/profile_card_widget.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  UserProfile? currentUser;
  List<AttendanceRecord> attendanceHistory = [
    AttendanceRecord(
      id: '1',
      companyName: 'Tech Solutions SARL',
      companyAddress: 'Abidjan, Plateau',
      userName: 'Jean Kouassi',
      userEmail: 'jean.kouassi@email.com',
      userPhone: '+225 07 08 09 10',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      qrCode: 'QR123456',
    ),
    AttendanceRecord(
      id: '2',
      companyName: 'Banque Atlantique',
      companyAddress: 'Abidjan, Cocody',
      userName: 'Marie Traore',
      userEmail: 'marie.traore@email.com',
      userPhone: '+225 01 02 03 04',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      qrCode: 'QR789012',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserProfile();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    // Démarrer l'animation après un court délai
    Future.delayed(Duration(milliseconds: 500), () {
      _fabAnimationController.forward();
    });
  }

  void _loadUserProfile() async {
    await UserService.instance.initialize();
    setState(() {
      currentUser = UserService.instance.currentUser;
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: currentUser == null
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          // AppBar personnalisé
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black87,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Pointage Présence',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: _refreshQRCode,
              ),
            ],
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 20),

                // Section Profil
                ProfileCardWidget(
                  user: currentUser!,
                  onTap: _navigateToProfile,
                ),

                SizedBox(height: 30),

                // Section QR Code principale
                _buildQRSection(),

                SizedBox(height: 40),

                // Titre Historique
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: Colors.black87),
                      SizedBox(width: 8),
                      Text(
                        'Historique des pointages',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${attendanceHistory.length}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),
              ],
            ),
          ),

          // Liste de l'historique
          attendanceHistory.isEmpty
              ? SliverToBoxAdapter(
            child: _buildEmptyHistory(),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _buildHistoryItem(attendanceHistory[index]);
              },
              childCount: attendanceHistory.length,
            ),
          ),

          // Espacement en bas
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Bouton flottant pour scanner
      floatingActionButton: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: _simulateQRScan,
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              icon: Icon(Icons.qr_code_scanner),
              label: Text('Scanner'),
              elevation: 8,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildQRSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Mon Code QR Personnel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Présentez ce code lors de vos pointages',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 24),

          // QR Code avec animation
          QRDisplayWidget(
            qrData: currentUser!.qrCode,
            userName: currentUser!.name,
            isInteractive: true,
            size: 220,
            onTap: () {
              _showQRDetails();
            },
          ),

          SizedBox(height: 16),

          // Bouton pour partager/copier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: _copyQRCode,
                icon: Icon(Icons.copy, color: Colors.grey[700]),
                label: Text(
                  'Copier',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              TextButton.icon(
                onPressed: _shareQRCode,
                icon: Icon(Icons.share, color: Colors.grey[700]),
                label: Text(
                  'Partager',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(AttendanceRecord record) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.black87,
            radius: 25,
            child: Icon(Icons.business, color: Colors.white, size: 20),
          ),
          title: Text(
            record.companyName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                record.companyAddress,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 4),
              Text(
                _formatDate(record.timestamp),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
          onTap: () => _showAttendanceDetails(record),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun pointage enregistré',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vos pointages apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Méthodes d'action
  void _navigateToProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );

    if (result == true) {
      _loadUserProfile(); // Recharger si modifié
    }
  }

  void _refreshQRCode() async {
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

  void _simulateQRScan() {
    final newRecord = AttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: 'Nouvelle Entreprise',
      companyAddress: 'Abidjan, Marcory',
      userName: currentUser!.name,
      userEmail: currentUser!.email,
      userPhone: currentUser!.phone,
      timestamp: DateTime.now(),
      qrCode: currentUser!.qrCode,
    );

    setState(() {
      attendanceHistory.insert(0, newRecord);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pointage enregistré avec succès!'),
        backgroundColor: Colors.black87,
        action: SnackBarAction(
          label: 'Voir',
          textColor: Colors.white,
          onPressed: () => _showAttendanceDetails(newRecord),
        ),
      ),
    );
  }

  void _showQRDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mon Code QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QRDisplayWidget(
              qrData: currentUser!.qrCode,
              userName: currentUser!.name,
              size: 200,
            ),
            SizedBox(height: 16),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _copyQRCode() {
    // Implémentation de la copie
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code QR copié!')),
    );
  }

  void _shareQRCode() {
    // Implémentation du partage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Partage du code QR...')),
    );
  }

  void _showAttendanceDetails(AttendanceRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAttendanceBottomSheet(record),
    );
  }

  Widget _buildAttendanceBottomSheet(AttendanceRecord record) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle du bottom sheet
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Titre
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Détails du pointage',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Divider(),

          // Contenu
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations de l'entreprise
                  _buildBottomSheetSection(
                    'Informations de l\'entreprise',
                    [
                      _buildBottomSheetRow('Nom', record.companyName),
                      _buildBottomSheetRow('Adresse', record.companyAddress),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Données du pointage
                  _buildBottomSheetSection(
                    'Données transmises lors du pointage',
                    [
                      _buildBottomSheetRow('Nom', record.userName),
                      _buildBottomSheetRow('Email', record.userEmail),
                      _buildBottomSheetRow('Téléphone', record.userPhone),
                      _buildBottomSheetRow('Date/Heure', _formatDateTime(record.timestamp)),
                      _buildBottomSheetRow('Code QR', record.qrCode),
                    ],
                  ),

                  Spacer(),

                  // Bouton fermer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Fermer', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        ...rows,
      ],
    );
  }

  Widget _buildBottomSheetRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}