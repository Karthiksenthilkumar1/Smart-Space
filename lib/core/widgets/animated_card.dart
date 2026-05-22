import 'package:flutter/material.dart';

class AnimatedCardWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedCardWrapper({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: onTap,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}