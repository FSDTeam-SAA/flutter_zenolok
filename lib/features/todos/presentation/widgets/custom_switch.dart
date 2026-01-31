import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: value ? const Color(0xFF34C759) : Colors.grey.shade300,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 39, // thumb width
            height: 24, // thumb height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100), // radius
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}