import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/brick_model.dart';
import '../../data/models/category_design.dart';
import '../controller/brick_controller.dart';

class CategoryEditorScreen extends StatelessWidget {
  const CategoryEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BrickController controller = Get.find<BrickController>(); // ✅ must be bound before opening

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // ✅ FIXED (keyboard)
      body: SafeArea(
        child: Obx(() {
          // ✅ FIXED: read Rx values INSIDE Obx (prevents "improper use of Obx")
          final CategoryDesign initial = controller.design.value;
          final bool isSaving = controller.isLoading.value;
          final String? errorText = controller.errorMessage.value;

          final bottomKeyboard = MediaQuery.of(context).viewInsets.bottom;

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(), // ✅ close keyboard on tap
            behavior: HitTestBehavior.translucent,
            child: SingleChildScrollView(
              // ✅ FIXED: scroll + keyboard padding
              padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + bottomKeyboard),
              child: CategoryEditorWidget(
                initial: initial, // ✅ FIXED
                isSaving: isSaving, // ✅ FIXED
                errorText: errorText, // ✅ FIXED
                onChanged: controller.updateDesign,
                onAdd: () async {
                  final BrickModel? created = await controller.createBrick();
                  if (created != null) {
                    Get.back(result: created);
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ===================== WIDGET =====================

class CategoryEditorWidget extends StatefulWidget {
  const CategoryEditorWidget({
    super.key,
    required this.initial,
    required this.onChanged,
    required this.onAdd,
    this.isSaving = false,
    this.errorText,
  });

  final CategoryDesign initial;
  final ValueChanged<CategoryDesign> onChanged;
  final Future<void> Function() onAdd;

  final bool isSaving;
  final String? errorText;

  @override
  State<CategoryEditorWidget> createState() => _CategoryEditorWidgetState();
}

class _CategoryEditorWidgetState extends State<CategoryEditorWidget> {
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

  static const List<_IconOpt> _icons = [
    _IconOpt(Icons.work_outline, 'ri-focus-2-fill'),
    _IconOpt(Icons.home_outlined, 'ri-home-4-line'),
    _IconOpt(Icons.school_outlined, 'ri-book-3-line'),
    _IconOpt(Icons.favorite_border, 'ri-heart-3-line'),
    _IconOpt(Icons.sports_soccer_outlined, 'ri-football-line'),
    _IconOpt(Icons.local_cafe_outlined, 'ri-cup-line'),
    _IconOpt(Icons.book_outlined, 'ri-book-open-line'),
    _IconOpt(Icons.flight_outlined, 'ri-flight-takeoff-line'),
    _IconOpt(Icons.shopping_bag_outlined, 'ri-shopping-bag-3-line'),
    _IconOpt(Icons.music_note_outlined, 'ri-music-2-line'),
    _IconOpt(Icons.movie_outlined, 'ri-movie-2-line'),
    _IconOpt(Icons.fitness_center_outlined, 'ri-dumbbell-line'),
    _IconOpt(Icons.pets_outlined, 'ri-bear-smile-line'),
    _IconOpt(Icons.camera_alt_outlined, 'ri-camera-3-line'),
    _IconOpt(Icons.computer_outlined, 'ri-computer-line'),
    _IconOpt(Icons.restaurant_outlined, 'ri-restaurant-2-line'),
    _IconOpt(Icons.bed_outlined, 'ri-hotel-bed-line'),
    _IconOpt(Icons.beach_access_outlined, 'ri-sun-line'),
    _IconOpt(Icons.event_outlined, 'ri-calendar-event-line'),
    _IconOpt(Icons.alarm_outlined, 'ri-alarm-line'),
    _IconOpt(Icons.directions_bike_outlined, 'ri-bike-line'),
    _IconOpt(Icons.directions_bus_outlined, 'ri-bus-line'),
    _IconOpt(Icons.local_hospital_outlined, 'ri-hospital-line'),
    _IconOpt(Icons.lightbulb_outline, 'ri-lightbulb-line'),
    _IconOpt(Icons.star_border, 'ri-star-line'),
    _IconOpt(Icons.workspaces_outline, 'ri-layout-grid-line'),
    _IconOpt(Icons.extension_outlined, 'ri-puzzle-line'),
    _IconOpt(Icons.brush_outlined, 'ri-brush-line'),
    _IconOpt(Icons.drive_eta_outlined, 'ri-car-line'),
    _IconOpt(Icons.games_outlined, 'ri-gamepad-line'),
    _IconOpt(Icons.emoji_food_beverage_outlined, 'ri-cake-3-line'),
  ];

  Color? _selectedColor;
  late _IconOpt _selectedIcon;

  late final TextEditingController _nameController;
  String _name = '';

  bool get _hasColor => _selectedColor != null;

  @override
  void initState() {
    super.initState();

    final init = widget.initial;

    _selectedColor = init.color;

    _selectedIcon = _icons.firstWhere(
          (x) => x.key == init.iconKey,
      orElse: () => _icons.first,
    );

    _name = init.name;
    _nameController = TextEditingController(text: _name);
  }

  @override
  void dispose() {
    _nameController.dispose(); // ✅ FIXED
    super.dispose();
  }

  void _notify() {
    widget.onChanged(
      CategoryDesign(
        color: _selectedColor,
        icon: _selectedIcon.icon,
        iconKey: _selectedIcon.key,
        name: _name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pillColor = _hasColor ? _selectedColor! : const Color(0xFFF1F1F1);
    final pillText =
    _nameController.text.trim().isEmpty ? 'Bricks' : _nameController.text.trim();

    final enabledBackColor =
    _hasColor ? const Color(0xFF444444) : const Color(0xFFDDDDDD);

    final addTextColor =
    (_hasColor && !widget.isSaving) ? const Color(0xFF444444) : const Color(0xFFE0E0E0);

    final canAdd = _hasColor && !widget.isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TOP ROW
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
              onPressed: _hasColor ? () => Get.back() : null,
            ),
            const Spacer(),
            InkWell(
              onTap: canAdd ? widget.onAdd : null,
              child: Row(
                children: [
                  Text(
                    widget.isSaving ? 'Adding...' : 'Add',
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

        const SizedBox(height: 8),

        // PILL
        Center(
          child: _CategoryHeaderPill(
            color: pillColor,
            icon: _hasColor ? _selectedIcon.icon : Icons.work_outline,
            text: pillText,
            enabled: _hasColor,
          ),
        ),

        const SizedBox(height: 10),

        // NAME FIELD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                readOnly: !_hasColor,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Bricks',
                  border: UnderlineInputBorder(),
                ),
                onChanged: (value) {
                  if (!_hasColor) return;
                  setState(() => _name = value); // ✅ FIXED: update model value
                  _notify();
                },
              ),
              if (widget.errorText != null && widget.errorText!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.errorText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // COLORS
        _RoundedPanel(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colors.map((c) {
                final isSelected = _selectedColor == c;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = c);
                    _notify();
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ICONS
        _RoundedPanel(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AbsorbPointer(
              absorbing: !_hasColor,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _icons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final opt = _icons[index];
                  final isSelected = opt.key == _selectedIcon.key;

                  final color = !_hasColor
                      ? const Color(0xFFD0D0D0)
                      : (isSelected ? const Color(0xFF444444) : const Color(0xFFB0B0B0));

                  return GestureDetector(
                    onTap: _hasColor
                        ? () {
                      setState(() => _selectedIcon = opt);
                      _notify();
                    }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected && _hasColor ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(opt.icon, size: 20, color: color),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IconOpt {
  final IconData icon;
  final String key;
  const _IconOpt(this.icon, this.key);
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
    final fg = enabled ? Colors.white : const Color(0xFFBDBDBD);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: fg,
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



