import 'package:flutter/material.dart';

// ───────────────────────── MODEL ─────────────────────────────────────────────

class CategoryDesign {
  /// Background color of the chip. Nullable so the editor can start "empty".
  final Color? color;
  final IconData icon;
  final String name;

  /// true = filled chip, false = outlined chip
  final bool filled;

  const CategoryDesign({
    this.color,
    required this.icon,
    required this.name,
    this.filled = true,
  });

  bool get isComplete => color != null;
}

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

  // initial categories shown in the chips row
  final List<CategoryDesign> _categories = [
    const CategoryDesign(
      color: Color(0xFF1D9BF0),
      icon: Icons.home_rounded,
      name: 'Home',
      filled: true,
    ),
    const CategoryDesign(
      color: Color(0xFFF6B700),
      icon: Icons.work_rounded,
      name: 'Work',
      filled: true,
    ),
    const CategoryDesign(
      color: Color(0xFFB277FF),
      icon: Icons.school_rounded,
      name: 'School',
      filled: false, // outlined purple
    ),
    const CategoryDesign(
      color: Color(0xFF22C55E),
      icon: Icons.person_rounded,
      name: 'Personal',
      filled: true,
    ),
    const CategoryDesign(
      color: Color(0xFFFF3366),
      icon: Icons.sports_soccer_rounded,
      name: 'Sport',
      filled: true,
    ),
  ];

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
                children: [
                  const _CategoryChip(
                    label: 'All',
                    icon: Icons.tune_rounded,
                    color: Color(0xFF9CA3AF),
                    filled: false,
                  ),
                  const SizedBox(width: 8),
                  ..._categories.map(
                        (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: c.name,
                        icon: c.icon,
                        color: c.color ?? Colors.grey,
                        filled: c.filled,
                      ),
                    ),
                  ),
                  _AddCategoryButton(
                    onTap: () async {
                      final result =
                      await Navigator.of(context).push<CategoryDesign>(
                        MaterialPageRoute(
                          builder: (_) => const CategoryEditorScreen(),
                        ),
                      );

                      if (result != null && result.isComplete) {
                        setState(() {
                          _categories.add(result);
                        });
                      }
                    },
                  ),
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

            // EVENTS LIST (main area) ----------------------------------------
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

  Widget _buildTabBody() {
    return const EventsListSection();
  }

}

// ───────────────────────── helpers (icons / chips / tabs) ───────────────────

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

class _AddCategoryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCategoryButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
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
  CategoryDesign _current = const CategoryDesign(
    color: null,
    icon: Icons.work_outline,
    name: 'Bricks',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: CategoryEditorWidget(
            initial: _current,
            onChanged: (design) {
              _current = design;
            },
            onSubmit: () {
              if (_current.isComplete) {
                Navigator.of(context).pop<CategoryDesign>(_current);
              }
            },
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── CATEGORY EDITOR WIDGET ────────────────────────────

class CategoryEditorWidget extends StatefulWidget {
  const CategoryEditorWidget({
    super.key,
    this.initial,
    this.onChanged,
    this.onSubmit,
  });

  final CategoryDesign? initial;
  final ValueChanged<CategoryDesign>? onChanged;
  final VoidCallback? onSubmit;

  @override
  State<CategoryEditorWidget> createState() => _CategoryEditorWidgetState();
}

class _CategoryEditorWidgetState extends State<CategoryEditorWidget> {
  // COLOR + ICON ARRAYS -------------------------------------------------------
  static const List<Color> _colors = [
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

  static const List<IconData> _icons = [
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

  Color? _selectedColor;
  IconData _selectedIcon = Icons.work_outline;
  String _name = 'Bricks';
  late final TextEditingController _nameController;

  bool get _hasColor => _selectedColor != null;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _selectedColor = init?.color;
    _selectedIcon = init?.icon ?? Icons.work_outline;
    _name = init?.name ?? 'Bricks';
    _nameController = TextEditingController(text: _name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged?.call(
      CategoryDesign(
        color: _selectedColor,
        icon: _selectedIcon,
        name: _name,
        filled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabledBackColor =
    _hasColor ? const Color(0xFF444444) : const Color(0xFFDDDDDD);
    final addTextColor =
    _hasColor ? const Color(0xFF444444) : const Color(0xFFE0E0E0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TOP BAR ------------------------------------------------------------
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: enabledBackColor,
              ),
              onPressed:
              _hasColor ? () => Navigator.of(context).pop() : null,
            ),
            const Spacer(),
            InkWell(
              onTap: _hasColor ? widget.onSubmit : null,
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
                  Icon(Icons.chevron_right, size: 18, color: addTextColor),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              side: const BorderSide(color: Color(0xFFE2E2E2)),
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

        const SizedBox(height: 8),

        // SELECTED CATEGORY PILL ---------------------------------------------
        Center(
          child: _CategoryPreviewPill(
            color: _hasColor
                ? _selectedColor!
                : const Color(0xFFF1F1F1),
            icon: _selectedIcon,
            text: _hasColor ? _name : 'Bricks',
            enabled: _hasColor,
          ),
        ),

        const SizedBox(height: 10),

        // EDITABLE NAME ------------------------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80),
          child: TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            readOnly: !_hasColor,
            decoration: InputDecoration(
              isDense: true,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE5E5E5)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: _hasColor
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
              color: _hasColor
                  ? const Color(0xFF444444)
                  : const Color(0xFFBDBDBD),
            ),
            onChanged: (value) {
              if (!_hasColor) return;
              setState(() {
                _name = value.isEmpty ? ' ' : value;
              });
              _notify();
            },
          ),
        ),

        const SizedBox(height: 20),

        // COLOR PANEL --------------------------------------------------------
        _RoundedPanel(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _ColorGrid(
              colors: _colors,
              selected: _selectedColor,
              onSelected: (c) {
                setState(() => _selectedColor = c);
                _notify();
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ICON PANEL ---------------------------------------------------------
        _RoundedPanel(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: AbsorbPointer(
              absorbing: !_hasColor,
              child: _IconGrid(
                icons: _icons,
                selected: _selectedIcon,
                enabled: _hasColor,
                onSelected: (icon) {
                  setState(() => _selectedIcon = icon);
                  _notify();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// pill used only inside editor
class _CategoryPreviewPill extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final bool enabled;

  const _CategoryPreviewPill({
    required this.color,
    required this.icon,
    required this.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = enabled ? Colors.white : const Color(0xFFBDBDBD);
    final iconColor = enabled ? Colors.white : const Color(0xFFBDBDBD);

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
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 6)]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

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
    const disabledColor = Color(0xFFD0D0D0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: icons.length,
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
            : (isSelected ? const Color(0xFF444444) : const Color(0xFFB0B0B0));

        return GestureDetector(
          onTap: enabled ? () => onSelected(icon) : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected && enabled ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
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
    // Make the Stack fill the entire available height so the line
    // continues even below the last card.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Stack(
            children: [
              // vertical line across the whole red area
              Positioned(
                left: 44,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 1,
                  color: const Color(0xFFE5E5E5),
                ),
              ),
              // scrollable cards
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
                  SizedBox(height: 16),
                ],
              ),
            ],
          ),
        );
      },
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
        // only label; the global line comes from the Stack
        SizedBox(
          width: 44,
          child: Align(
            alignment: Alignment.topLeft,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  Row(
                    children: [
                      const _InfoRow(
                        icon: Icons.access_time,
                        text: '',
                      ),
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
