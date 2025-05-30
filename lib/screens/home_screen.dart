import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import 'attendance_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pointage Présence'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Section QR Code
          Container(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.qr_code,
                    size: 150,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Simulation du scan QR
                    _simulateQRScan();
                  },
                  icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: Text('Scanner QR Code', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey[300], thickness: 1),

          // Section Historique
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Historique des pointages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: attendanceHistory.length,
              itemBuilder: (context, index) {
                final record = attendanceHistory[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.business, color: Colors.white),
                    ),
                    title: Text(
                      record.companyName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${_formatDate(record.timestamp)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceDetailScreen(record: record),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _simulateQRScan() {
    // Simulation d'un nouveau pointage
    final newRecord = AttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: 'Nouvelle Entreprise',
      companyAddress: 'Abidjan, Marcory',
      userName: 'Utilisateur Test',
      userEmail: 'test@email.com',
      userPhone: '+225 05 06 07 08',
      timestamp: DateTime.now(),
      qrCode: 'QR${DateTime.now().millisecondsSinceEpoch}',
    );

    setState(() {
      attendanceHistory.insert(0, newRecord);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pointage enregistré avec succès!'),
        backgroundColor: Colors.black,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}