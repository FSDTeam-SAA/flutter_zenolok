import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 24.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  horizontalPadding, 16, horizontalPadding, 0),
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
                  for (final icon in [
                    Icons.search_rounded,
                    Icons.notifications_none_rounded,
                    Icons.person_outline_rounded,
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

            // CATEGORY PILLS
            SizedBox(
              height: 36,
              child: ListView(
                padding:
                const EdgeInsets.symmetric(horizontal: horizontalPadding),
                scrollDirection: Axis.horizontal,
                children: const [
                  _CategoryChip(label: 'All'),
                  _CategoryChip(label: 'Home', color: Color(0xFF2563EB), selected: true),
                  _CategoryChip(label: 'Work', color: Color(0xFFF59E0B)),
                  _CategoryChip(label: 'School', color: Color(0xFF8B5CF6)),
                  _CategoryChip(label: 'Personal', color: Color(0xFF10B981)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TABS ROW
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  const _TabLabel(text: 'Upcoming', selected: true),
                  const SizedBox(width: 16),
                  const _TabLabel(text: 'Past'),
                  const SizedBox(width: 16),
                  const _TabLabel(text: 'All'),
                  const Spacer(),
                  _CircleIcon(icon: Icons.tune_rounded, size: 32),
                  const SizedBox(width: 8),
                  _CircleIcon(icon: Icons.sort_rounded, size: 32),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LIST
            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _TimelineLabel(text: 'Now'),
                        SizedBox(height: 64),
                        _TimelineLabel(text: '1 day'),
                        SizedBox(height: 64),
                        _TimelineLabel(text: '4 days'),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Cards
                    Expanded(
                      child: ListView(
                        children: const [
                          _EventCard(
                            color: Color(0xFF10B981),
                            title: 'Body check',
                            date: '17 JUN 2026',
                            time: '08 : 00 AM - 09 : 00 AM',
                            location: '20, Farm Road',
                          ),
                          SizedBox(height: 12),
                          _EventCard(
                            color: Color(0xFFF59E0B),
                            title: 'Exhibition week',
                            date: '18 JUN 2026 - 21 JUN 2026',
                            time: '08 : 00 AM      09 : 00 AM',
                            location: 'Asia Expo',
                          ),
                          SizedBox(height: 12),
                          _EventCard(
                            color: Color(0xFF2563EB),
                            title: 'Family dinner',
                            date: '21 JUN 2026',
                            time: 'All day',
                            location: 'Home',
                            allDay: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAV
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  const _CircleIcon({required this.icon, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.black87),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  const _CategoryChip({
    required this.label,
    this.color = const Color(0xFF9CA3AF),
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? color.withOpacity(0.15) : const Color(0xFFF3F4F6);
    final textColor = selected ? color : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                )),
          ],
        ),
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
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.black : const Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 4),
        if (selected)
          Container(
            width: 18,
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

class _TimelineLabel extends StatelessWidget {
  final String text;
  const _TimelineLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Color color;
  final String title;
  final String date;
  final String time;
  final String location;
  final bool allDay;

  const _EventCard({
    required this.color,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    this.allDay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 96,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
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
                  // Title + location
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.location_on_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active indicator bar
          Container(
            width: 64,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _NavItem(icon: Icons.calendar_today_outlined, label: 'Home'),
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Events',
                active: true,
              ),
              _NavItem(icon: Icons.list_alt_outlined, label: 'Todos'),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavItem({required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.black : const Color(0xFF9CA3AF);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
          ),
        ),
      ],
    );
  }
}
