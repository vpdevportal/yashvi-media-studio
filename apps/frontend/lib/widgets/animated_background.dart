import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/theme/app_colors.dart';

class AnimatedBackground extends StatelessWidget {
  final AnimationController rotateController;

  const AnimatedBackground({
    super.key,
    required this.rotateController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        AnimatedBuilder(
          animation: rotateController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(rotateController.value * 2 - 1, -1),
                  end: Alignment(1 - rotateController.value * 2, 1),
                  colors: const [
                    AppColors.background,
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    AppColors.background,
                  ],
                ),
              ),
            );
          },
        ),
        // Floating orbs
        ...List.generate(3, (index) => _buildFloatingOrb(index)),
      ],
    );
  }

  Widget _buildFloatingOrb(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.primaryLight,
    ];
    final sizes = [300.0, 200.0, 250.0];
    final positions = [
      const Alignment(-1.5, -0.8),
      const Alignment(1.5, 0.5),
      const Alignment(-0.5, 1.5),
    ];

    return AnimatedBuilder(
      animation: rotateController,
      builder: (context, child) {
        final offset = math.sin(rotateController.value * 2 * math.pi + index) * 20;
        return Positioned.fill(
          child: Align(
            alignment: positions[index],
            child: Transform.translate(
              offset: Offset(offset, offset),
              child: Container(
                width: sizes[index],
                height: sizes[index],
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors[index].withValues(alpha:0.3),
                      colors[index].withValues(alpha:0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

