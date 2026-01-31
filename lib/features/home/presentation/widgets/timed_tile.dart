import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/calendar_event.dart';
import '../controller/event_controller.dart';
import '../screens/event_editor_screen.dart';
import 'badge.dart' as custom_badge;
import 'base_event_card.dart';
import 'calendar_helpers.dart';
import 'checklist_row.dart';

class TimedTile extends StatefulWidget {
  const TimedTile({super.key, required this.event, required this.onToggle});

  final CalendarEvent event;
  final void Function(String item, bool checked) onToggle;

  @override
  State<TimedTile> createState() => _TimedTileState();
}

class _TimedTileState extends State<TimedTile> with TickerProviderStateMixin {
  bool _expanded = false;

  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  Future<void> _editEvent(BuildContext context) async {
    final edited = await Navigator.of(context).push<CalendarEvent>(
      MaterialPageRoute(
        builder: (_) => EventEditorScreen(
          initialDate: widget.event.start,
          existingEvent: widget.event,
        ),
      ),
    );

    if (edited == null) return;

    final ec = Get.find<EventController>();

    await ec.updateEventFromUi(widget.event.id, edited);
    await ec.loadMonth(widget.event.start);

    if (!_sameMonth(widget.event.start, edited.start)) {
      await ec.loadMonth(edited.start);
    }

    await ec.ensureTodosLoadedForDay(CalendarHelpers.dateOnly(edited.start));
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final hasChecklist = e.checklist.isNotEmpty;

    const double checklistIndentFromContentLeft = 68;

    return BaseEventCard(
      marginTop: 6,
      verticalPadding: 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 3),
              SizedBox(
                width: 56,
                child: InkWell(
                  onTap: () => _editEvent(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('h:mm').format(e.start),
                            style: GoogleFonts.dongle(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              height: 16 / 24,
                              color: const Color(0xFF656565),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            DateFormat('a').format(e.start),
                            style: GoogleFonts.dongle(
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              height: 16 / 11,
                              color: const Color(0xFF9D9D9D),
                            ),
                          ),
                        ],
                      ),
                      if (e.end != null) ...[
                        const SizedBox(height: 0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('h:mm').format(e.end!),
                              style: GoogleFonts.dongle(
                                fontWeight: FontWeight.w400,
                                fontSize: 19,
                                height: 16 / 19,
                                color: const Color(0xFF9D9D9D),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              DateFormat('a').format(e.end!),
                              style: GoogleFonts.dongle(
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                                height: 16 / 11,
                                color: const Color(0xFF9D9D9D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _editEvent(context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title,
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
                            if (e.location != null)
                              Text(
                                e.location!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dongle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                  height: 16 / 13,
                                  letterSpacing: 0,
                                  color: const Color(0xFF9D9D9D),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 18,
                        color: Colors.black45,
                      ),
                      if (hasChecklist)
                        const Positioned(
                          right: -6,
                          top: -6,
                          child: custom_badge.Badge(number: 2),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        CupertinoIcons.list_bullet,
                        size: 18,
                        color: Colors.black45,
                      ),
                      if (hasChecklist)
                        Positioned(
                          right: -6,
                          top: -12,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: const Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Transform.rotate(
                        angle: _expanded ? 3.1416 : 0,
                        child: const Icon(
                          Icons.expand_more,
                          size: 20,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasChecklist)
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: checklistIndentFromContentLeft,
                        top: 10,
                        right: 4,
                        bottom: 2,
                      ),
                      child: Column(
                        children: [
                          for (final raw in e.checklist) ...[
                            ChecklistRow(
                              raw: raw,
                              onTap: (checked) => widget.onToggle(raw, checked),
                            ),
                            const SizedBox(height: 6),
                          ],
                          const SizedBox(height: 2),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'New todo',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 16 / 14,
                                letterSpacing: 0,
                                color: const Color(0xFFD5D5D5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
