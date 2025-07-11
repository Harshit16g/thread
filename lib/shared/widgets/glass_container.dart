import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final BorderRadius? customBorderRadius; // Allow custom border radius
  final Color? color;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.customBorderRadius,
    this.color,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    // Use the custom radius if provided, otherwise use the default
    final effectiveRadius = customBorderRadius ?? BorderRadius.circular(borderRadius);

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.2),
            borderRadius: effectiveRadius,
            border: border,
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
