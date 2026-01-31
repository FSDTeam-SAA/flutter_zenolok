import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllDayPill extends StatelessWidget {
  const AllDayPill({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        height: 21,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFEDF5FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFDFDFDF),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          'All day',
          textAlign: TextAlign.center,
          style: GoogleFonts.dongle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 16 / 16,
            letterSpacing: 0,
            color: value
                ? const Color(0xFF4A87FF)
                : const Color(0xFFB6B5B5),
          ),
        ),
      ),
    );
  }
}
