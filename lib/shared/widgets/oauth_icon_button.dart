import 'package:flutter/material.dart';
import 'package:tabl/shared/widgets/glass_container.dart';

class OAuthIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;

  const OAuthIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        iconSize: 24,
      ),
    );
  }
}
