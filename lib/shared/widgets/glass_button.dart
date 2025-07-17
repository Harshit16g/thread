import 'package:flutter/material.dart';
import 'package:tabl/shared/widgets/glass_container.dart';

class GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        child: child,
      ),
    );
  }
}
