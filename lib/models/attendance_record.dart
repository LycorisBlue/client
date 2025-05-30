class AttendanceRecord {
  final String id;
  final String companyName;
  final String companyAddress;
  final String userName;
  final String userEmail;
  final String userPhone;
  final DateTime timestamp;
  final String qrCode;

  AttendanceRecord({
    required this.id,
    required this.companyName,
    required this.companyAddress,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.timestamp,
    required this.qrCode,
  });
}