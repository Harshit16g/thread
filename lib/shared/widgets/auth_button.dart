import 'package:flutter/material.dart';

enum AuthButtonStyle {
  glass,
  solid,
}

class AuthButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final AuthButtonStyle style;
  final Color solidColor;
  final Color solidTextColor;

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.style = AuthButtonStyle.glass,
    this.solidColor = Colors.black,
    this.solidTextColor = Colors.white,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSolid = widget.style == AuthButtonStyle.solid;
    
    final Color effectiveColor = isSolid && _isPressed ? widget.solidTextColor : widget.solidColor;
    final Color effectiveTextColor = isSolid && _isPressed ? widget.solidColor : widget.solidTextColor;
    
    final double glassOpacity = _isPressed ? 0.35 : 0.2;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSolid ? effectiveColor : Color.fromRGBO(76, 86, 107, glassOpacity), // Using blueGrey with opacity
          borderRadius: BorderRadius.circular(12),
          border: isSolid ? null : Border.all(color: const Color.fromRGBO(255, 255, 255, 0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : DefaultTextStyle(
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  child: widget.child,
                ),
        ),
      ),
    );
  }
}
