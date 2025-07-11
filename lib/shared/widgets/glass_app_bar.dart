import 'package:flutter/material.dart';
import 'glass_container.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: GlassContainer(
          borderRadius: 16,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: AppBar(
            title: Text(title),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
