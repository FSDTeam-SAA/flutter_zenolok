import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE1E3EC);
    const iconColor = Color(0xFFC7CAD3);

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Icon(icon, size: 14, color: iconColor),
    );
  }
}
