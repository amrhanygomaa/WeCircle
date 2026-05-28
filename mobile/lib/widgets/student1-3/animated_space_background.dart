import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedSpaceBackground extends StatelessWidget {
  const AnimatedSpaceBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep Navy Background
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF03001C),
          ),
        ),
        
        // Cosmic Gradients/Nebula
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.5),
                radius: 1.5,
                colors: [
                  const Color(0xFF1B0044).withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 10.seconds),
        ),

        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.8, 0.6),
                radius: 1.2,
                colors: [
                  const Color(0xFF003366).withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 15.seconds),
        ),

        // Floating Particles (Stars)
        ...List.generate(40, (index) {
          final random = Random();
          final x = random.nextDouble();
          final y = random.nextDouble();
          final size = random.nextDouble() * 3 + 1;
          final duration = (random.nextDouble() * 3 + 2).seconds;

          return Positioned(
            left: x * MediaQuery.of(context).size.width,
            top: y * MediaQuery.of(context).size.height,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: size,
                    spreadRadius: size / 2,
                  ),
                ],
              ),
            ).animate(onPlay: (controller) => controller.repeat())
             .fade(begin: 0.2, end: 1.0, duration: duration)
             .then()
             .fade(begin: 1.0, end: 0.2, duration: duration),
          );
        }),
      ],
    );
  }
}
