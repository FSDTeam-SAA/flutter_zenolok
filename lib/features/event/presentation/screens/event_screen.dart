import 'package:flutter/material.dart';

// ───────────────────────── EVENTS SCREEN ─────────────────────────────────────

enum EventsTab { upcoming, past, all }

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  static const _horizontalPadding = 24.0;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  EventsTab _selectedTab = EventsTab.upcoming;

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
                EventsScreen._horizontalPadding,
                16,
                EventsScreen._horizontalPadding,
                0,
              ),
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
                  horizontal: EventsScreen._horizontalPadding,
                ),
                physics: const BouncingScrollPhysics(),
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
                    icon: Icons.sports_soccer_rounded,
                    color: Color(0xFFFF3366),
                    filled: true,
                  ),
                  SizedBox(width: 8),
                  _AddCategoryButton(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TABS ROW -------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: EventsScreen._horizontalPadding,
              ),
              child: Row(
                children: [
                  _TabLabel(
                    text: 'Upcoming',
                    selected: _selectedTab == EventsTab.upcoming,
                    onTap: () {
                      setState(() => _selectedTab = EventsTab.upcoming);
                    },
                  ),
                  const Spacer(),
                  _TabLabel(
                    text: 'Past',
                    selected: _selectedTab == EventsTab.past,
                    onTap: () {
                      setState(() => _selectedTab = EventsTab.past);
                    },
                  ),
                  const Spacer(),
                  _TabLabel(
                    text: 'All',
                    selected: _selectedTab == EventsTab.all,
                    onTap: () {
                      setState(() => _selectedTab = EventsTab.all);
                    },
                  ),
                  const Spacer(),
                  const _CircleIcon(icon: Icons.sort_rounded, size: 32),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // EVENTS LIST (RED AREA) ----------------------------------------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: EventsScreen._horizontalPadding,
                ),
                child: _buildTabBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// This decides what appears in the red area for each tab.
  Widget _buildTabBody() {
    switch (_selectedTab) {
      case EventsTab.upcoming:
      // Only Upcoming shows the timeline list
        return const EventsListSection();
      case EventsTab.past:
      case EventsTab.all:
      // Past & All: nothing in the red area
        return const SizedBox.shrink(); // or Container()
    }
  }
}

// ───────────────────────── helpers (top bar / chips / tabs) ─────────────────

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  const _CircleIcon({required this.icon, this.size = 36, super.key});

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
    super.key,
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

// CLICKABLE + BUTTON  ---------------------------------------------------------
class _AddCategoryButton extends StatelessWidget {
  const _AddCategoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CategoryEditorScreen(),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  const _TabLabel({
    required this.text,
    this.selected = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    selected ? const Color(0xFF444444) : const Color(0xFFC4C4C4);

    return InkWell(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}

// ───────────────────────── CATEGORY EDITOR SCREEN ────────────────────────────

class CategoryEditorScreen extends StatefulWidget {
  const CategoryEditorScreen({super.key});

  @override
  State<CategoryEditorScreen> createState() => _CategoryEditorScreenState();
}

class _CategoryEditorScreenState extends State<CategoryEditorScreen> {
  // sample data
  final List<Color> _colors = const [
    Color(0xFFFF4B4B),
    Color(0xFFFF9F0A),
    Color(0xFFFFD60A),
    Color(0xFF34C759),
    Color(0xFF30B0C7),
    Color(0xFF007AFF),
    Color(0xFF5E5CE6),
    Color(0xFFFF2D55),
    Color(0xFFFFCCCC),
    Color(0xFFFFE0B2),
    Color(0xFFFFF2B2),
    Color(0xFFC8E6C9),
    Color(0xFFB2EBF2),
    Color(0xFFBBDEFB),
    Color(0xFFE1BEE7),
    Color(0xFFF8BBD0),
    Color(0xFF8D6E63),
    Color(0xFF607D8B),
  ];

  final List<IconData> _icons = const [
    Icons.work_outline,
    Icons.home_outlined,
    Icons.school_outlined,
    Icons.favorite_border,
    Icons.sports_soccer_outlined,
    Icons.local_cafe_outlined,
    Icons.book_outlined,
    Icons.flight_outlined,
    Icons.shopping_bag_outlined,
    Icons.music_note_outlined,
    Icons.movie_outlined,
    Icons.fitness_center_outlined,
    Icons.pets_outlined,
    Icons.camera_alt_outlined,
    Icons.computer_outlined,
    Icons.restaurant_outlined,
    Icons.bed_outlined,
    Icons.beach_access_outlined,
    Icons.event_outlined,
    Icons.alarm_outlined,
    Icons.directions_bike_outlined,
    Icons.directions_bus_outlined,
    Icons.local_hospital_outlined,
    Icons.lightbulb_outline,
    Icons.star_border,
    Icons.workspaces_outline,
    Icons.extension_outlined,
    Icons.brush_outlined,
    Icons.drive_eta_outlined,
    Icons.games_outlined,
    Icons.emoji_food_beverage_outlined,
  ];

  Color? _selectedColor; // null => first (grey) state
  IconData _selectedIcon = Icons.work_outline;
  String _name = 'Bricks';
  late final TextEditingController _nameController;

  bool get _hasSelectedColor => _selectedColor != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabledBackColor =
    _hasSelectedColor ? const Color(0xFF444444) : const Color(0xFFDDDDDD);

    final addTextColor =
    _hasSelectedColor ? const Color(0xFF444444) : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BAR --------------------------------------------------------
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: enabledBackColor,
                    ),
                    onPressed:
                    _hasSelectedColor ? () => Navigator.of(context).pop() : null,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _hasSelectedColor
                        ? () {
                      // TODO: handle "Add" action
                      Navigator.pop(context);
                    }
                        : null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: addTextColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: addTextColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // COLLABORATION PILL UNDER ADD ----------------------------------
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: collaboration action
                  },
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    side: const BorderSide(
                      color: Color(0xFFE2E2E2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(
                    Icons.group_outlined,
                    size: 14,
                    color: Color(0xFFBDBDBD),
                  ),
                  label: const Text(
                    'Collaboration',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFBDBDBD),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // SELECTED CATEGORY PILL -----------------------------------------
            Center(
              child: _CategoryHeaderPill(
                color: _hasSelectedColor
                    ? _selectedColor!
                    : const Color(0xFFF1F1F1),
                icon: _selectedIcon,
                text: _hasSelectedColor ? _name : 'Bricks',
                enabled: _hasSelectedColor,
              ),
            ),

            const SizedBox(height: 10),

            // EDITABLE NAME ("Work"/"Bricks") --------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                readOnly: !_hasSelectedColor, // locked in first state
                decoration: InputDecoration(
                  isDense: true,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: _hasSelectedColor
                          ? const Color(0xFFE5E5E5)
                          : const Color(0xFFF0F0F0),
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF444444)),
                  ),
                ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _hasSelectedColor
                      ? const Color(0xFF444444)
                      : const Color(0xFFBDBDBD),
                ),
                onChanged: (value) {
                  if (!_hasSelectedColor) return;
                  setState(() {
                    _name = value.isEmpty ? ' ' : value;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // CONTENT (scrollable) -------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    // COLOR PANEL
                    _RoundedPanel(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: _ColorGrid(
                          colors: _colors,
                          selected: _selectedColor,
                          onSelected: (c) {
                            setState(() {
                              _selectedColor = c;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ICON PANEL
                    _RoundedPanel(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: AbsorbPointer(
                          absorbing: !_hasSelectedColor,
                          child: _IconGrid(
                            icons: _icons,
                            selected: _selectedIcon,
                            enabled: _hasSelectedColor,
                            onSelected: (icon) {
                              setState(() => _selectedIcon = icon);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// pill at the top ("Work" / "Bricks")
class _CategoryHeaderPill extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final bool enabled;

  const _CategoryHeaderPill({
    required this.color,
    required this.icon,
    required this.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
    enabled ? Colors.white : const Color(0xFFBDBDBD);
    final iconColor =
    enabled ? Colors.white : const Color(0xFFBDBDBD);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// rounded white/grey card
class _RoundedPanel extends StatelessWidget {
  final Widget child;
  const _RoundedPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

// color grid
class _ColorGrid extends StatelessWidget {
  final List<Color> colors;
  final Color? selected;
  final ValueChanged<Color> onSelected;

  const _ColorGrid({
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((c) {
        final isSelected = selected != null && c == selected;
        return GestureDetector(
          onTap: () => onSelected(c),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border:
              isSelected ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: c.withOpacity(0.4),
                  blurRadius: 6,
                )
              ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// icon grid
class _IconGrid extends StatelessWidget {
  final List<IconData> icons;
  final IconData selected;
  final ValueChanged<IconData> onSelected;
  final bool enabled;

  const _IconGrid({
    required this.icons,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final disabledColor = const Color(0xFFD0D0D0);

    return GridView.builder(
      itemCount: icons.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final icon = icons[index];
        final isSelected = icon == selected;

        final color = !enabled
            ? disabledColor
            : (isSelected
            ? const Color(0xFF444444)
            : const Color(0xFFB0B0B0));

        return GestureDetector(
          onTap: enabled ? () => onSelected(icon) : null,
          child: Container(
            decoration: BoxDecoration(
              color:
              isSelected && enabled ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

// ───────────────────────── EVENTS LIST / TIMELINE ───────────────────────────

class EventsListSection extends StatelessWidget {
  const EventsListSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Stack gives us ONE continuous vertical line behind all items.
    return Stack(
      children: [
        Positioned(
          left: 44,
          top: 0,
          bottom: 0,
          child: Container(
            width: 1,
            color: const Color(0xFFE5E5E5),
          ),
        ),
        ListView(
          physics: const BouncingScrollPhysics(),
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
        ),
      ],
    );
  }
}

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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
    super.key,
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
      child: IntrinsicHeight(
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
                      const Icon(Icons.location_on_outlined,
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
                  const _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: '',
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textSub,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // time row + trailing icons
                  Row(
                    children: [
                      const _InfoRow(
                        icon: Icons.access_time,
                        text: '',
                      ),
                      const SizedBox(width: 0),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSub,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.autorenew,
                          size: 16, color: textSub),
                      const SizedBox(width: 8),
                      const Icon(Icons.notifications_none_rounded,
                          size: 16, color: textSub),
                      const SizedBox(width: 8),
                      const Icon(Icons.more_horiz,
                          size: 16, color: textSub),
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
    super.key,
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

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count, super.key});

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

class _ParticipantCircle extends StatelessWidget {
  const _ParticipantCircle({super.key});

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
