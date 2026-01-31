import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GhostPill extends StatelessWidget {
  const GhostPill({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFB6B5B5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath, width: 16, height: 16, color: borderColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.dongle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: borderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
