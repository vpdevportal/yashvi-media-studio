import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LogoSection extends StatelessWidget {
  final AnimationController pulseController;

  const LogoSection({
    super.key,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated logo
        AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3 + pulseController.value * 0.2),
                    blurRadius: 40 + pulseController.value * 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 64,
                color: Colors.white,
              ),
            );
          },
        ),
        const SizedBox(height: 48),
        // Title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.textSecondary, Colors.white, AppColors.textSecondary],
          ).createShader(bounds),
          child: const Text(
            'YASHVI',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w200,
              letterSpacing: 24,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'MEDIA STUDIO',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 8,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 24),
        // Tagline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            color: Colors.white.withOpacity(0.03),
          ),
          child: Text(
            'Create • Inspire • Transform',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}

