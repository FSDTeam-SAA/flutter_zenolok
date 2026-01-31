import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/calendar_event.dart';
import '../controller/brick_controller.dart';
import 'calendar_helpers.dart';

class StreakBar extends StatelessWidget {
  const StreakBar({super.key, required this.event, required this.day});

  final CalendarEvent event;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrickController>();
    final color = CalendarHelpers.eventColor(controller.bricks, event);

    final d = CalendarHelpers.dateOnly(day);
    final s = CalendarHelpers.dateOnly(event.start);
    final e = CalendarHelpers.dateOnly(event.end!);

    // is this day start / end of streak
    final isStart = d.isAtSameMomentAs(s);
    final isEnd = d.isAtSameMomentAs(e);

    // show label only on start day
    final showLabel = isStart;

    final radius = BorderRadius.horizontal(
      left: isStart ? const Radius.circular(10) : Radius.zero,
      right: isEnd ? const Radius.circular(10) : Radius.zero,
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5D6),
        borderRadius: radius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      alignment: Alignment.centerLeft,
      child: showLabel
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 3,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    event.title.isNotEmpty
                        ? event.title[0].toUpperCase() +
                              event.title.substring(1)
                        : event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      height: 16 / 8,
                      letterSpacing: -0.2,
                      color: const Color(0xFF7B6200),
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
