import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  static const _horizontalPadding = 24.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BAR --------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  _horizontalPadding, 16, _horizontalPadding, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Events',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  for (final icon in const [
                    Icons.search_rounded,
                    Icons.notifications_none_rounded,
                    Icons.settings_outlined,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _CircleIcon(icon: icon),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CATEGORY PILLS -------------------------------------------------
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                ),
                children: const [
                  _CategoryChip(
                    label: 'All',
                    icon: Icons.tune_rounded,
                    color: Color(0xFF9CA3AF),
                    filled: false,
                  ),
                  SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Home',
                    icon: Icons.home_rounded,
                    color: Color(0xFF1D9BF0),
                    filled: true,
                  ),
                  SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Work',
                    icon: Icons.work_rounded,
                    color: Color(0xFFF6B700),
                    filled: true,
                  ),
                  SizedBox(width: 8),
                  _CategoryChip(
                    label: 'School',
                    icon: Icons.school_rounded,
                    color: Color(0xFFB277FF),
                    filled: false,
                  ),
                  SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Personal',
                    icon: Icons.person_rounded,
                    color: Color(0xFF22C55E),
                    filled: true,
                  ),
                  SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Sport',
                    icon: Icons.sports_soccer_rounded, // or any sports icon you like
                    color: Color(0xFFFF3366),          // pink/red like your screenshot
                    filled: true,
                  ),
                  SizedBox(width: 8),
                  _AddCategoryButton(),                // circular "+" button
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TABS ROW -------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              child: Row(
                children: const [
                  _TabLabel(text: 'Upcoming', selected: true),
                  Spacer(),
                  _TabLabel(text: 'Past'),
                  Spacer(),
                  _TabLabel(text: 'All'),
                  Spacer(),
                  _CircleIcon(icon: Icons.sort_rounded, size: 32),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TIMELINE + CARDS ----------------------------------------------
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                ),
                child: EventsListSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _AddCategoryButton extends StatelessWidget {
  const _AddCategoryButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF9CA3AF),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.add,
        size: 18,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}


// ───────────────────────── helpers (top bar / chips / tabs) ─────────────────

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  const _CircleIcon({required this.icon, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: Colors.black87),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = filled ? color : Colors.white;
    final borderColor = filled ? color : color.withOpacity(0.35);
    final contentColor = filled ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: contentColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String text;
  final bool selected;
  const _TabLabel({required this.text, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final color =
    selected ? const Color(0xFF444444) : const Color(0xFFC4C4C4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        if (selected)
          Container(
            width: 22,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

// ───────────────────────── EVENTS LIST / TIMELINE ───────────────────────────

class EventsListSection extends StatelessWidget {
  const EventsListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _EventTimelineItem(
          timelineLabel: 'Now',
          color: Color(0xFF34C759),
          title: 'Body check',
          date: '17 JUN 2026',
          time: '08 : 00 AM  -  09 : 00 AM',
          location: '20, Farm Road',
          badgeCount: 2,
        ),
        SizedBox(height: 12),
        _EventTimelineItem(
          timelineLabel: '1 day',
          color: Color(0xFFFFCC00),
          title: 'Exhibition week',
          date: '18 JUN 2026  -  21 JUN 2026',
          time: '08 : 00 AM          09 : 00 AM',
          location: 'Asia Expo',
          badgeCount: 2,
          showParticipantsRow: true,
        ),
        SizedBox(height: 12),
        _EventTimelineItem(
          timelineLabel: '4 days',
          color: Color(0xFF32ADE6),
          title: 'Family dinner',
          date: '21 JUN 2026',
          time: 'All day',
          location: 'Home',
          badgeCount: 2,
        ),
      ],
    );
  }
}

/// Label column ("Now / 1 day / 4 days") + vertical line + card.
class _EventTimelineItem extends StatelessWidget {
  final String timelineLabel;
  final Color color;
  final String title;
  final String date;
  final String time;
  final String location;
  final int badgeCount;
  final bool showParticipantsRow;

  const _EventTimelineItem({
    required this.timelineLabel,
    required this.color,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.badgeCount,
    this.showParticipantsRow = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          // vertical line behind cards
          Positioned(
            left: 44,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: const Color(0xFFE5E5E5),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    timelineLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EventCard(
                  color: color,
                  title: title,
                  date: date,
                  time: time,
                  location: location,
                  badgeCount: badgeCount,
                  showParticipantsRow: showParticipantsRow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── EVENT CARD ───────────────────────────────────────

class _EventCard extends StatelessWidget {
  final Color color;
  final String title;
  final String date;
  final String time;
  final String location;
  final int badgeCount;
  final bool showParticipantsRow;

  const _EventCard({
    required this.color,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.badgeCount,
    required this.showParticipantsRow,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFFF7F7F7);
    const textMain = Color(0xFF666666);
    const textSub = Color(0xFFB0B0B0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // colored strip
          Container(
            width: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + location + badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textMain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.location_on_outlined,
                          size: 14, color: textSub),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 11,
                            color: textSub,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _Badge(count: badgeCount),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // date row
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: date,
                  ),

                  const SizedBox(height: 4),

                  // time row + trailing icons
                  Row(
                    children: [
                      const _InfoRow(
                        icon: Icons.access_time,
                        text: '',
                      ),
                      // little hack: reuse style; we only want text next to icon
                      const SizedBox(width: 0),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSub,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.autorenew, size: 16, color: textSub),
                      const SizedBox(width: 8),
                      Icon(Icons.notifications_none_rounded,
                          size: 16, color: textSub),
                      const SizedBox(width: 8),
                      Icon(Icons.more_horiz, size: 16, color: textSub),
                    ],
                  ),

                  if (showParticipantsRow) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        _ParticipantCircle(),
                        SizedBox(width: 4),
                        _ParticipantCircle(),
                        SizedBox(width: 4),
                        _ParticipantCircle(),
                        SizedBox(width: 4),
                        _ParticipantCircle(),
                        Spacer(),
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 16,
                          color: textSub,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    const textSub = Color(0xFFB0B0B0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textSub),
        const SizedBox(width: 6),
        if (text.isNotEmpty)
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: textSub,
            ),
          ),
      ],
    );
  }
}

/// Red circular badge with number.
class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Color(0xFFFF3B30),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Little grey participant circles (second card).
class _ParticipantCircle extends StatelessWidget {
  const _ParticipantCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
    );
  }
}



