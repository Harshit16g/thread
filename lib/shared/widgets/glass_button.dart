import 'package:flutter/material.dart';
import 'glass_container.dart';

class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: GlassContainer(
        borderRadius: 12,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : DefaultTextStyle(
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}
