import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/brick_model.dart';
import '../../data/models/category_design.dart';
import '../controller/brick_controller.dart';

class CategoryEditorScreen extends StatelessWidget {
  const CategoryEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BrickController controller = Get.find<BrickController>();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Obx(() {
          final CategoryDesign initial = controller.design.value;
          final bool isSaving = controller.isLoading.value;
          final String? errorText = controller.errorMessage.value;

          final bottomKeyboard = MediaQuery.of(context).viewInsets.bottom;

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + bottomKeyboard),
              child: CategoryEditorWidget(
                initial: initial,
                isSaving: isSaving,
                errorText: errorText,
                onChanged: controller.updateDesign,
                onAdd: () async {
                  final BrickModel? created = await controller.createBrick();
                  if (created != null) Get.back(result: created);
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
  // 10 x 4 grid (like your screenshot)
  static const List<Color> _colors = [
    // row 1
    Color(0xFFFF3B30),
    Color(0xFFFF9500),
    Color(0xFFFFCC00),
    Color(0xFF34C759),
    Color(0xFF00C7BE),
    Color(0xFF30B0C7),
    Color(0xFF32ADE6),
    Color(0xFF007AFF),
    Color(0xFF5856D6),
    Color(0xFFFF2D55),

    // row 2
    Color(0xFFFFD7D5),
    Color(0xFFFFE3C4),
    Color(0xFFFFF3C4),
    Color(0xFFD9F4DE),
    Color(0xFFCFF5F2),
    Color(0xFFD6F3F6),
    Color(0xFFD6EEFF),
    Color(0xFFD6E8FF),
    Color(0xFFE3E1FF),
    Color(0xFFFFD6E4),

    // row 3
    Color(0xFFFFFFFF),
    Color(0xFFF2F2F2),
    Color(0xFFE6E6E6),
    Color(0xFFDADADA),
    Color(0xFFCCCCCC),
    Color(0xFFBDBDBD),
    Color(0xFFAAAAAA),
    Color(0xFF8E8E93),
    Color(0xFF6B6B6B),
    Color(0xFF3A3A3A),

    // row 4
    Color(0xFF8D6E63),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFF455A64),
    Color(0xFF1C1C1E),
    Color(0xFF2C2C2E),
    Color(0xFF48484A),
    Color(0xFF636366),
    Color(0xFF0A84FF),
    Color(0xFF5E5CE6),
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
    _nameController.dispose();
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

    final enabledBackColor = _hasColor ? const Color(0xFF444444) : const Color(0xFFDDDDDD);

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
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: enabledBackColor),
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

        const SizedBox(height: 10),

        // PILL
        Center(
          child: _CategoryHeaderPill(
            color: pillColor,
            icon: _hasColor ? _selectedIcon.icon : Icons.work_outline,
            text: pillText,
            enabled: _hasColor,
          ),
        ),

        const SizedBox(height: 12),

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
                  setState(() => _name = value);
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

        // COLORS (red marked area 1)
        _RoundedPanel(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _colors.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final c = _colors[index];
                final isSelected = _selectedColor == c;

                final isWhite = c.value == const Color(0xFFFFFFFF).value;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = c);
                    _notify();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 6,
                          offset: Offset(0, 2),
                          color: Color(0x14000000),
                        )
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // base dot
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isWhite ? const Color(0xFFE5E5EA) : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),

                        // selection ring (white ring like screenshot)
                        if (isSelected)
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),

                        // outer subtle ring (helps on white backgrounds)
                        if (isSelected)
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0x22000000), width: 1),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ICONS (red marked area 2)
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
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final opt = _icons[index];
                  final isSelected = opt.key == _selectedIcon.key;

                  final iconColor = !_hasColor
                      ? const Color(0xFFD0D0D0)
                      : (isSelected ? const Color(0xFF4A4A4A) : const Color(0xFFB0B0B0));

                  return GestureDetector(
                    onTap: _hasColor
                        ? () {
                      setState(() => _selectedIcon = opt);
                      _notify();
                    }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isSelected && _hasColor) ? const Color(0xFFF1F1F1) : Colors.transparent,
                      ),
                      child: Center(
                        child: Icon(opt.icon, size: 20, color: iconColor),
                      ),
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
        color: const Color(0xFFF2F3F5), // closer to screenshot
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7E7EA), width: 1),
      ),
      child: child,
    );
  }
}
