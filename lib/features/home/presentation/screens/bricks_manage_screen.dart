import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../data/models/brick_model.dart';
import '../controller/brick_controller.dart';
import '../widgets/cateogry_widget.dart';
import 'brick_edit_screen.dart';

class BricksManageScreen extends StatefulWidget {
  const BricksManageScreen({super.key});

  @override
  State<BricksManageScreen> createState() => _BricksManageScreenState();
}

class _BricksManageScreenState extends State<BricksManageScreen> {
  late BrickController _brickController;

  @override
  void initState() {
    super.initState();
    // Get the controller
    _brickController = Get.find<BrickController>();
    // Schedule load after build completes to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _brickController.loadBricks();
    });
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
    };
    return iconMap[key] ?? Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bricks Manage',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final isLoading = _brickController.isLoading.value;
          final errorMessage = _brickController.errorMessage.value;
          final bricks = _brickController.bricks;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Error: $errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _brickController.loadBricks(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (bricks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No bricks found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Add New Bricks Button
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        _brickController.resetDesign();
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryEditorScreen(),
                          ),
                        );
                        // Reload bricks if creation was successful
                        if (result != null) {
                          _brickController.loadBricks();
                        }
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                        ),

                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bricks Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    mainAxisExtent: 48,
                  ),
                  itemCount: bricks.length,
                  itemBuilder: (context, index) {
                    final brick = bricks[index];
                    return _buildBrickCard(brick);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBrickCard(BrickModel brick) {
    final brickColor = _hexToColor(brick.color);
    final brickIcon = _iconFromKey(brick.icon);

    return GestureDetector(
      onLongPress: () => _showDeleteConfirmation(brick),
      onTap: () async {
        // Navigate to edit screen and reload bricks on return
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BrickEditScreen(brick: brick)),
        );
        // Reload bricks if update was successful
        if (result != null) {
          _brickController.loadBricks();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: brickColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: brickColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Icon on the left
            Icon(brickIcon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            // Brick name on the right
            Expanded(
              child: Text(
                brick.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BrickModel brick) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delete Brick',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to delete "${brick.name}"?',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        // Call delete API
                        final success = await _brickController.deleteBrick(
                          brick.id,
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '"${brick.name}" deleted successfully',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (!success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete "${brick.name}"'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
