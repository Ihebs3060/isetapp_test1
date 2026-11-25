import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isOutlined;
  final Color? color;
  final Color? textColor;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isOutlined = false,
    this.color,
    this.textColor,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? (widget.isOutlined ? Colors.white : Colors.white);
    final effectiveTextColor = widget.textColor ?? (widget.isOutlined ? Colors.white : kPrimaryBlue);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: 1 - _controller.value,
        child: SizedBox(
          width: double.infinity,
          child: widget.isOutlined
              ? OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    disabledForegroundColor: effectiveTextColor,
                    side: BorderSide(color: effectiveColor, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(widget.text,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                )
              : ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: effectiveColor,
                    disabledForegroundColor: effectiveTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(widget.text,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
        ),
      ),
    );
  }
}
