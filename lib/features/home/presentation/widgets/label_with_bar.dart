import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LabelWithBar extends StatelessWidget {
  const LabelWithBar({
    super.key,
    required this.barColor,
    required this.text,
    this.textColor,
  });

  final Color barColor;
  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            height: 16 / 11,
            letterSpacing: 0,
            color: textColor ?? const Color(0xFF7B6200),
          ),
        ),
      ],
    );
  }
}
