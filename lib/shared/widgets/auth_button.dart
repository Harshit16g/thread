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
      if (child is Text) {
        return PrimaryButton(
          onPressed: onPressed,
          text: (child as Text).data!,
        );
      }
    }

    return GlassButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
