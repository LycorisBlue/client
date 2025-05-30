import 'package:flutter/material.dart';

class QRDisplayWidget extends StatelessWidget {
  final String qrData;

  QRDisplayWidget({required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code,
            size: 120,
            color: Colors.black,
          ),
          SizedBox(height: 8),
          Text(
            'QR Code',
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}