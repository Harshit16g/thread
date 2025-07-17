import 'package:flutter/material.dart';
import 'package:tabl/shared/widgets/glass_button.dart';
import 'package:tabl/shared/widgets/primary_button.dart';

enum AuthButtonStyle { solid, glass }

class AuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final AuthButtonStyle style;
  final Color? solidColor;
  final Color? solidTextColor;

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style = AuthButtonStyle.glass,
    this.solidColor,
    this.solidTextColor,
  });

  @override
  Widget build(BuildContext context) {
    if (style == AuthButtonStyle.solid) {
      return PrimaryButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(solidColor),
          foregroundColor: MaterialStateProperty.all(solidTextColor),
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
      );
    }

    return GlassButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
