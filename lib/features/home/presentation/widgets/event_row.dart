import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/calendar_event.dart';

class EventRow extends StatelessWidget {
  const EventRow({
    super.key,
    required this.e,
    required this.height,
    this.indicatorColor,
  });

  final CalendarEvent e;
  final double height;
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    const double fs = 8.0;
    const double barHeight = 10.0;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(-4, 2),
            child: Container(
              width: 2,
              height: barHeight,
              decoration: BoxDecoration(
                color: indicatorColor ?? const Color(0xFF3AA1FF),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 0.1),
          Expanded(
            child: Text(
              e.title.isNotEmpty
                  ? e.title[0].toUpperCase() + e.title.substring(1)
                  : e.title,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: fs,
                fontWeight: FontWeight.w700,
                height: 16 / 8,
                letterSpacing: -0.2,
                color: const Color(0xFF154E68),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
