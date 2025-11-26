import 'package:flutter/material.dart';

class CategoryEditorScreen extends StatelessWidget {
  const CategoryEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: CategoryEditorWidget(
            // start in grey state like 2nd screen
            initial: const CategoryDesign(
              color: null,
              icon: Icons.work_outline,
              name: 'Bricks',
            ),
            onChanged: (design) {
              // here you get color, icon, and name
              // print(design.color);
            },
          ),
        ),
      ),
    );
  }
}


class CategoryEditorWidget extends StatefulWidget {
  const CategoryEditorWidget({
    super.key,
    this.initial,
    this.onChanged,
  });

  /// pass null or color=null to start in the grey state
  final CategoryDesign? initial;

  /// gets called whenever color/icon/name changes
  final ValueChanged<CategoryDesign>? onChanged;

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
      CategoryDesign(color: _selectedColor, icon: _selectedIcon, name: _name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pillColor = _hasColor ? _selectedColor! : const Color(0xFFF1F1F1);
    final enabledBackColor =
    _hasColor ? const Color(0xFF444444) : const Color(0xFFDDDDDD);
    final addTextColor =
    _hasColor ? const Color(0xFF444444) : const Color(0xFFE0E0E0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TOP BAR (back + Add + Collaboration) -------------------------------
        Row(
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: enabledBackColor,
            ),
            const Spacer(),
            Row(
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

        // PILL ----------------------------------------------------------------
        Center(
          child: _CategoryHeaderPill(
            color: pillColor,
            icon: _selectedIcon,
            text: _name,
            enabled: _hasColor,
          ),
        ),

        const SizedBox(height: 10),

        // NAME FIELD ---------------------------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80),
          child: TextField(
            controller: _nameController,
            readOnly: !_hasColor,
            textAlign: TextAlign.center,
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

        // CONTENT (COLOR + ICON) --------------------------------------------
        _RoundedPanel(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        _RoundedPanel(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            child: Icon(icon, size: 20, color: color),
          ),
        );
      },
    );
  }
}


class CategoryDesign {
  final Color? color;        // null = grey / disabled
  final IconData icon;
  final String name;

  const CategoryDesign({
    this.color,
    required this.icon,
    required this.name,
  });

  bool get isComplete => color != null;
}
