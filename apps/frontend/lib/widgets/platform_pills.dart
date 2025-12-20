import 'package:flutter/material.dart';

class PlatformPills extends StatelessWidget {
  const PlatformPills({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildPill(Icons.phone_iphone, 'iOS'),
        _buildPill(Icons.android, 'Android'),
        _buildPill(Icons.language, 'Web'),
        _buildPill(Icons.desktop_mac, 'Desktop'),
      ],
    );
  }

  Widget _buildPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha:0.1)),
        color: Colors.white.withValues(alpha:0.03),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha:0.6)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha:0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

