import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/brick_model.dart';
import '../../data/models/category_design.dart';
import '../controller/brick_controller.dart';

class CategoryEditorScreen extends StatefulWidget {
  const CategoryEditorScreen({super.key});

  @override
  State<CategoryEditorScreen> createState() => _CategoryEditorScreenState();
}

class _CategoryEditorScreenState extends State<CategoryEditorScreen> {
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // 👉 this focus node is unused but kept (no behavior change)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BrickController controller = Get.find<BrickController>();

    return Obx(() {
      final CategoryDesign initial = controller.design.value;
      final bool isSaving = controller.isLoading.value;
      final String? errorText = controller.errorMessage.value;
      final bool hasColor = initial.color != null;

      final addTextColor = (hasColor && !isSaving)
          ? const Color(0xFF444444)
          : const Color(0xFFE0E0E0);

      final canAdd = hasColor && !isSaving;

      final bottomKeyboard = MediaQuery.of(context).viewInsets.bottom;

      return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: GestureDetector(
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Colors.black,
              ),
            ),
            onPressed: hasColor ? () => Get.back() : null,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: InkWell(
                onTap: canAdd
                    ? () async {
                        final BrickModel? created =
                            await controller.createBrick();
                        if (created != null) Get.back(result: created);
                      }
                    : null,
                child: Row(
                  children: [
                    Text(
                      isSaving ? 'Adding...' : 'Add',
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
            ),
          ],
        ),
        body: SafeArea(
          child: GestureDetector(
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
          ),
        ),
      );
    });
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
  // 10 x 4 palette (like screenshot)
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

  // MORE ICONS (8 columns like screenshot)
  static const List<_IconOpt> _icons = [
    // row 1 (matches screenshot style)
    _IconOpt(Icons.widgets_outlined, 'grid'),
    _IconOpt(Icons.wb_sunny_outlined, 'sun'),
    _IconOpt(Icons.light_mode_outlined, 'sun_alt'),
    _IconOpt(Icons.nightlight_outlined, 'moon'),
    _IconOpt(Icons.star_outline, 'star'),
    _IconOpt(Icons.cloud_outlined, 'cloud'),
    _IconOpt(Icons.eco_outlined, 'leaf'),
    _IconOpt(Icons.pets_outlined, 'animal'),

    // row 2
    _IconOpt(Icons.home_outlined, 'home'),
    _IconOpt(Icons.work_outline, 'briefcase'),
    _IconOpt(Icons.shopping_cart_outlined, 'cart'),
    _IconOpt(Icons.directions_bike_outlined, 'bike'),
    _IconOpt(Icons.stacked_bar_chart_outlined, 'stats'),
    _IconOpt(Icons.person_outline, 'person'),
    _IconOpt(Icons.delete_outline, 'trash'),
    _IconOpt(Icons.school_outlined, 'cap'),

    // row 3
    _IconOpt(Icons.umbrella_outlined, 'umbrella'),
    _IconOpt(Icons.checkroom_outlined, 'tshirt'),
    _IconOpt(Icons.dry_cleaning_outlined, 'dress'),
    _IconOpt(Icons.bathtub_outlined, 'bath'),
    _IconOpt(Icons.weekend_outlined, 'sofa'),
    _IconOpt(Icons.bed_outlined, 'bed'),
    _IconOpt(Icons.light_outlined, 'lamp'),
    _IconOpt(Icons.bolt_outlined, 'bolt'),

    // row 4
    _IconOpt(Icons.image_outlined, 'image'),
    _IconOpt(Icons.park_outlined, 'tree'),
    _IconOpt(Icons.sentiment_very_satisfied_outlined, 'ghost_like'),
    _IconOpt(Icons.celebration_outlined, 'balloon_like'),
    _IconOpt(Icons.palette_outlined, 'palette'),
    _IconOpt(Icons.style_outlined, 'cards'),
    _IconOpt(Icons.sports_esports_outlined, 'game'),
    _IconOpt(Icons.gps_fixed, 'target'),

    // row 5
    _IconOpt(Icons.calendar_month_outlined, 'calendar'),
    _IconOpt(Icons.music_note_outlined, 'music'),
    _IconOpt(Icons.movie_outlined, 'movie'),
    _IconOpt(Icons.headphones_outlined, 'headphones'),
    _IconOpt(Icons.menu_book_outlined, 'book'),
    _IconOpt(Icons.radio_outlined, 'radio'),
    _IconOpt(Icons.campaign_outlined, 'megaphone'),
    _IconOpt(Icons.timer_outlined, 'timer'),

    // row 6
    _IconOpt(Icons.camera_alt_outlined, 'camera'),
    _IconOpt(Icons.tv_outlined, 'tv'),
    _IconOpt(Icons.phone_iphone_outlined, 'phone'),
    _IconOpt(Icons.watch_outlined, 'watch'),
    _IconOpt(Icons.favorite_border, 'heart'),
    _IconOpt(Icons.diamond_outlined, 'diamond'),
    _IconOpt(Icons.content_cut_outlined, 'scissors'),
    _IconOpt(Icons.local_florist_outlined, 'flower'),

    // row 7
    _IconOpt(Icons.local_fire_department_outlined, 'fire'),
    _IconOpt(Icons.power_settings_new_outlined, 'power'),
    _IconOpt(Icons.outdoor_grill_outlined, 'campfire'),
    _IconOpt(Icons.sentiment_satisfied_alt_outlined, 'smile'),
    _IconOpt(Icons.apartment_outlined, 'apartment'),
    _IconOpt(Icons.account_balance_outlined, 'bank'),
    _IconOpt(Icons.holiday_village_outlined, 'tent'),

    // row 8
    _IconOpt(Icons.storefront_outlined, 'store'),
    _IconOpt(Icons.train_outlined, 'train'),
    _IconOpt(Icons.tram_outlined, 'tram'),
    _IconOpt(Icons.directions_car_outlined, 'car'),
    _IconOpt(Icons.local_shipping_outlined, 'truck'),
    _IconOpt(Icons.flight_outlined, 'plane'),
    _IconOpt(Icons.rocket_launch_outlined, 'rocket'),
    _IconOpt(Icons.science_outlined, 'lab'),

    // extra (so you have a big list like screenshot)
    _IconOpt(Icons.restaurant_outlined, 'food'),
    _IconOpt(Icons.local_cafe_outlined, 'coffee'),
    _IconOpt(Icons.fitness_center_outlined, 'gym'),
    _IconOpt(Icons.sports_soccer_outlined, 'football'),
    _IconOpt(Icons.beach_access_outlined, 'beach'),
    _IconOpt(Icons.local_hospital_outlined, 'hospital'),
    _IconOpt(Icons.lightbulb_outline, 'idea'),
    _IconOpt(Icons.extension_outlined, 'puzzle'),

    _IconOpt(Icons.brush_outlined, 'brush'),
    _IconOpt(Icons.edit_outlined, 'pen'),
    _IconOpt(Icons.color_lens_outlined, 'color'),
    _IconOpt(Icons.cleaning_services_outlined, 'clean'),
    _IconOpt(Icons.lock_outline, 'lock'),
    _IconOpt(Icons.security_outlined, 'security'),
    _IconOpt(Icons.language_outlined, 'globe'),
    _IconOpt(Icons.map_outlined, 'map'),

    _IconOpt(Icons.location_on_outlined, 'pin'),
    _IconOpt(Icons.credit_card_outlined, 'card'),
    _IconOpt(Icons.attach_money, 'money'),
    _IconOpt(Icons.savings_outlined, 'savings'),
    _IconOpt(Icons.shopping_bag_outlined, 'bag'),
    _IconOpt(Icons.local_mall_outlined, 'mall'),
    _IconOpt(Icons.list_alt_outlined, 'list'),
    _IconOpt(Icons.task_alt_outlined, 'task'),

    _IconOpt(Icons.chat_bubble_outline, 'chat'),
    _IconOpt(Icons.forum_outlined, 'forum'),
    _IconOpt(Icons.mail_outline, 'mail'),
    _IconOpt(Icons.share_outlined, 'share'),
    _IconOpt(Icons.link_outlined, 'link'),
    _IconOpt(Icons.group_outlined, 'group'),
    _IconOpt(Icons.handshake_outlined, 'handshake'),
    _IconOpt(Icons.public_outlined, 'public'),
  ];

  Color? _selectedColor;
  late _IconOpt _selectedIcon;

  late final TextEditingController _nameController;
  late final FocusNode _nameFocus; // 👉 NEW: focus node for blinking cursor
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
    _nameFocus = FocusNode();

    // 👉 Sync initial design with controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notify(); // Ensure controller has the current design
      if (_hasColor) {
        _nameFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose(); // 👉 NEW: dispose focus node
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
    final pillColor =
        _hasColor ? _selectedColor! : const Color(0xFFF1F1F1);
    final pillText = _nameController.text.trim().isEmpty
        ? 'Bricks'
        : _nameController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PILL
        Center(
          child: _CategoryHeaderPill(
            color: pillColor,
            icon: _hasColor ? _selectedIcon.icon : Icons.widgets_outlined,
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
                focusNode: _nameFocus,
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

              if (widget.errorText != null &&
                  widget.errorText!.trim().isNotEmpty)
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
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _colors.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final c = _colors[index];
                final isSelected = _selectedColor == c;
                final isWhite =
                    c.toARGB32() == const Color(0xFFFFFFFF).toARGB32();

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = c);
                    _notify();

                    _nameFocus.requestFocus();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
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
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isWhite
                                  ? const Color(0xFFE5E5EA)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 3),
                            ),
                          ),
                        if (isSelected)
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0x22000000),
                                  width: 1),
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

        // ICONS (now 8 columns + more icons)
        _RoundedPanel(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AbsorbPointer(
              absorbing: !_hasColor,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _icons.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final opt = _icons[index];
                  final isSelected =
                      opt.key == _selectedIcon.key;

                  final iconColor = !_hasColor
                      ? const Color(0xFFD0D0D0)
                      : (isSelected
                          ? const Color(0xFF4A4A4A)
                          : const Color(0xFFB0B0B0));

                  return GestureDetector(
                    onTap: _hasColor
                        ? () {
                            setState(() => _selectedIcon = opt);
                            _notify(); // Update controller with new icon
                          }
                        : null,
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 120),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isSelected && _hasColor)
                            ? const Color(0xFFF1F1F1)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Icon(opt.icon,
                            size: 20, color: iconColor),
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
      padding:
      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE7E7EA),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
