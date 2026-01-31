import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/calendar_event.dart';
import '../controller/event_controller.dart';
import '../screens/event_editor_screen.dart';
import 'badge.dart' as custom_badge;
import 'base_event_card.dart';
import 'label_with_bar.dart';

class StreakTile extends StatelessWidget {
  const StreakTile({super.key, required this.event});

  final CalendarEvent event;

  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  @override
  Widget build(BuildContext context) {
    return BaseEventCard(
      child: Row(
        children: [
          const LabelWithBar(
            barColor: Color(0xFFFFC542),
            text: 'Streak',
            textColor: Color(0xFFDA9A00),
          ),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFD5D5D5),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              event.title.isNotEmpty
                  ? event.title[0].toUpperCase() + event.title.substring(1)
                  : event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dongle(
                fontWeight: FontWeight.w400,
                fontSize: 24,
                height: 16 / 24,
                letterSpacing: 0,
                color: const Color(0xFF656565),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final edited = await Navigator.of(context).push<CalendarEvent>(
                MaterialPageRoute(
                  builder: (_) => EventEditorScreen(
                    initialDate: event.start,
                    existingEvent: event,
                  ),
                ),
              );

              if (edited == null) return;

              final ec = Get.find<EventController>();

              await ec.updateEventFromUi(event.id, edited);
              await ec.loadMonth(event.start);

              if (!_sameMonth(event.start, edited.start)) {
                await ec.loadMonth(edited.start);
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  AppImages.message_icon,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  color: Colors.black45,
                  colorBlendMode: BlendMode.srcIn,
                ),
                const Positioned(right: -8, top: -8, child: custom_badge.Badge(number: 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
