import 'package:flutter/material.dart';

class QRDisplayWidget extends StatefulWidget {
  final String qrData;
  final String? userName;
  final VoidCallback? onTap;
  final bool isInteractive;
  final double size;

  const QRDisplayWidget({
    Key? key,
    required this.qrData,
    this.userName,
    this.onTap,
    this.isInteractive = false,
    this.size = 200,
  }) : super(key: key);

  @override
  _QRDisplayWidgetState createState() => _QRDisplayWidgetState();
}

class _QRDisplayWidgetState extends State<QRDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Animation continue
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isInteractive ? _scaleAnimation.value : 1.0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                ),
                border: Border.all(
                  color: Colors.black87,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                  if (widget.isInteractive)
                    BoxShadow(
                      color: Colors.black.withOpacity(_glowAnimation.value * 0.3),
                      blurRadius: 30,
                      offset: Offset(0, 0),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Code QR avec effet de brillance
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // QR Code principal
                        Icon(
                          Icons.qr_code,
                          size: widget.size * 0.5,
                          color: Colors.black87,
                        ),

                        // Effet de brillance
                        if (widget.isInteractive)
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _glowAnimation.value * 0.3,
                                child: Icon(
                                  Icons.qr_code,
                                  size: widget.size * 0.5,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  // Informations sous le QR
                  if (widget.userName != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.userName!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    // Texte par défaut
                    Text(
                      'Mon QR Code',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  SizedBox(height: 4),

                  // ID du QR (masqué partiellement)
                  Text(
                    _formatQRId(widget.qrData),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatQRId(String qrData) {
    if (qrData.length <= 8) return qrData;
    return '${qrData.substring(0, 4)}...${qrData.substring(qrData.length - 4)}';
  }
}

// Widget QR simple pour les listes ou espaces compacts
class CompactQRWidget extends StatelessWidget {
  final String qrData;
  final double size;
  final VoidCallback? onTap;

  const CompactQRWidget({
    Key? key,
    required this.qrData,
    this.size = 60,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black87, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.qr_code,
          size: size * 0.6,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// Widget QR avec statut (pour l'historique)
class QRStatusWidget extends StatelessWidget {
  final String qrData;
  final bool isActive;
  final DateTime? timestamp;
  final double size;

  const QRStatusWidget({
    Key? key,
    required this.qrData,
    this.isActive = true,
    this.timestamp,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isActive ? Colors.green : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.qr_code,
            size: size * 0.6,
            color: isActive ? Colors.black87 : Colors.grey,
          ),
        ),

        // Indicateur de statut
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}