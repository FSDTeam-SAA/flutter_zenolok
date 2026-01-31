import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Badge extends StatelessWidget {
  const Badge({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFF5757),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$number',
        textAlign: TextAlign.center,
        style: GoogleFonts.dongle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 10 / 14,
          letterSpacing: 0,
          color: Colors.white,
        ),
      ),
    );
  }
}
