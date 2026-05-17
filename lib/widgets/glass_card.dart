import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double opacity;
  final Color? borderColor;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.opacity = 0.07,
    this.borderColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: shadows ??
                [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.08),
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}