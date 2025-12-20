import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StatusCard extends StatelessWidget {
  final String serverStatus;
  final bool isConnected;

  const StatusCard({
    super.key,
    required this.serverStatus,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? AppColors.success : Colors.white.withOpacity(0.3),
              boxShadow: isConnected
                  ? [BoxShadow(color: AppColors.success.withOpacity(0.5), blurRadius: 12)]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            serverStatus,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

