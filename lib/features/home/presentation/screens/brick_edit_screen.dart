import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/brick_model.dart';
import '../../data/models/category_design.dart';
import '../controller/brick_controller.dart';
import '../widgets/cateogry_widget.dart';

class BrickEditScreen extends StatefulWidget {
  final BrickModel brick;

  const BrickEditScreen({super.key, required this.brick});

  @override
  State<BrickEditScreen> createState() => _BrickEditScreenState();
}

class _BrickEditScreenState extends State<BrickEditScreen> {
  @override
  void initState() {
    super.initState();
    // Pre-fill the controller with current brick data immediately
    final controller = Get.find<BrickController>();

    // Convert hex color to Flutter Color
    final color = _hexToColor(widget.brick.color);

    // Find the icon from the icon key
    final icon = _iconFromKey(widget.brick.icon);

    controller.updateDesign(
      CategoryDesign(
        color: color,
        icon: icon,
        iconKey: widget.brick.icon,
        name: widget.brick.name,
      ),
    );
  }

  @override
  void dispose() {
    // Reset design when leaving the screen
    final controller = Get.find<BrickController>();
    controller.resetDesign();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length != 6) return const Color(0xFFBFC1C8);
    return Color(int.parse('FF$h', radix: 16));
  }

  IconData _iconFromKey(String key) {
    const iconMap = <String, IconData>{
      'grid': Icons.widgets_outlined,
      'sun': Icons.wb_sunny_outlined,
      'sun_alt': Icons.light_mode_outlined,
      'moon': Icons.nightlight_outlined,
      'star': Icons.star_outline,
      'cloud': Icons.cloud_outlined,
      'leaf': Icons.eco_outlined,
      'animal': Icons.pets_outlined,
      'home': Icons.home_outlined,
      'briefcase': Icons.work_outline,
      'cart': Icons.shopping_cart_outlined,
      'bike': Icons.directions_bike_outlined,
      'stats': Icons.stacked_bar_chart_outlined,
      'person': Icons.person_outline,
      'trash': Icons.delete_outline,
      'cap': Icons.school_outlined,
      'umbrella': Icons.umbrella_outlined,
      'tshirt': Icons.checkroom_outlined,
      'dress': Icons.dry_cleaning_outlined,
      'bath': Icons.bathtub_outlined,
      'sofa': Icons.weekend_outlined,
      'bed': Icons.bed_outlined,
      'lamp': Icons.light_outlined,
      'bolt': Icons.bolt_outlined,
      'image': Icons.image_outlined,
      'tree': Icons.park_outlined,
      'target': Icons.gps_fixed,
      'calendar': Icons.calendar_month_outlined,
      'music': Icons.music_note_outlined,
      'movie': Icons.movie_outlined,
      'headphones': Icons.headphones_outlined,
      'book': Icons.menu_book_outlined,
      'radio': Icons.radio_outlined,
      'megaphone': Icons.campaign_outlined,
      'timer': Icons.timer_outlined,
      'camera': Icons.camera_alt_outlined,
      'tv': Icons.tv_outlined,
      'phone': Icons.phone_iphone_outlined,
      'watch': Icons.watch_outlined,
      'heart': Icons.favorite_border,
      'diamond': Icons.diamond_outlined,
      'scissors': Icons.content_cut_outlined,
      'flower': Icons.local_florist_outlined,
      'fire': Icons.local_fire_department_outlined,
      'power': Icons.power_settings_new_outlined,
      'campfire': Icons.outdoor_grill_outlined,
      'smile': Icons.sentiment_satisfied_alt_outlined,
      'apartment': Icons.apartment_outlined,
      'ri-focus-2-fill': Icons.work_outline,
      'ri-brain-fill': Icons.psychology_outlined,
    };
    return iconMap[key] ?? Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final BrickController controller = Get.find<BrickController>();

    return Obx(() {
      final CategoryDesign initial = controller.design.value;
      final bool isSaving = controller.isLoading.value;
      final String? errorText = controller.errorMessage.value;
      final bool hasColor = initial.color != null;

      final updateTextColor = (hasColor && !isSaving)
          ? const Color(0xFF444444)
          : const Color(0xFFE0E0E0);

      final canUpdate = hasColor && !isSaving;

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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.black,
            ),
            onPressed: () => Get.back(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: InkWell(
                onTap: canUpdate
                    ? () async {
                        final BrickModel? updated = await controller
                            .updateBrick(widget.brick.id);
                        if (updated != null) Get.back(result: updated);
                      }
                    : null,
                child: Row(
                  children: [
                    Text(
                      isSaving ? 'Updating...' : 'Update',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: updateTextColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 18, color: updateTextColor),
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
                  final BrickModel? updated = await controller.updateBrick(
                    widget.brick.id,
                  );
                  if (updated != null) Get.back(result: updated);
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}
