import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/calendar_event.dart';
import '../controller/event_controller.dart';
import '../screens/event_editor_screen.dart';
import 'base_event_card.dart';
import 'calendar_helpers.dart';
import 'label_with_bar.dart';

class AllDayTile extends StatelessWidget {
  const AllDayTile({super.key, required this.event});

  final CalendarEvent event;

  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  @override
  Widget build(BuildContext context) {
    return BaseEventCard(
      height: 38,
      verticalPadding: 8,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const LabelWithBar(
                  barColor: Color(0xFF3AA1FF),
                  text: 'All day',
                  textColor: Color(0xFF3AA1FF),
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
                        ? event.title[0].toUpperCase() +
                              event.title.substring(1)
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
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Image.asset(
              AppImages.fresh_icon,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              color: Colors.black45,
              colorBlendMode: BlendMode.srcIn,
            ),
            onPressed: () async {
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

              await ec.ensureTodosLoadedForDay(CalendarHelpers.dateOnly(edited.start));
            },
          ),
        ],
      ),
    );
  }
}
