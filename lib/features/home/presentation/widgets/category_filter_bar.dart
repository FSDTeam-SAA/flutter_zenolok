import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../data/models/brick_model.dart';
import '../controller/brick_controller.dart';
import 'cateogry_widget.dart';           // for EventCategory + extension



typedef CategoryFilterChanged = void Function(Set<String> activeIds);

//--------------------

class CategoryFilterBar extends StatelessWidget {
  /// Active brick IDs (empty = All selected)
  final Set<String> activeIds;

  /// Returns updated active set
  final ValueChanged<Set<String>> onChange;

  /// Tap on "+" button (optional)
  final VoidCallback? onAddPressed;

  /// Show "+" button (default true)
  final bool showAddButton;

  const CategoryFilterBar({
    super.key,
    required this.activeIds,
    required this.onChange,
    this.onAddPressed,
    this.showAddButton = true,
  });

  // "#RRGGBB" or "#AARRGGBB" -> Color
  Color _hexToColor(String hex, {Color fallback = const Color(0xFF3AA1FF)}) {
    final raw = hex.replaceAll('#', '').trim();
    try {
      if (raw.length == 6) return Color(int.parse('FF$raw', radix: 16));
      if (raw.length == 8) return Color(int.parse(raw, radix: 16));
    } catch (_) {}
    return fallback;
  }

  // iconKey -> IconData
  IconData _iconFromKey(String key) {
    const map = <String, IconData>{
      'ri-focus-2-fill': Icons.work_outline,
      'ri-home-4-line': Icons.home_outlined,
      'ri-book-3-line': Icons.school_outlined,
      'ri-heart-3-line': Icons.favorite_border,
      'ri-football-line': Icons.sports_soccer_outlined,
      'ri-cup-line': Icons.local_cafe_outlined,
      'ri-book-open-line': Icons.book_outlined,
      'ri-flight-takeoff-line': Icons.flight_outlined,
      'ri-shopping-bag-3-line': Icons.shopping_bag_outlined,
      'ri-music-2-line': Icons.music_note_outlined,
      'ri-movie-2-line': Icons.movie_outlined,
      'ri-dumbbell-line': Icons.fitness_center_outlined,
      'ri-bear-smile-line': Icons.pets_outlined,
      'ri-camera-3-line': Icons.camera_alt_outlined,
      'ri-computer-line': Icons.computer_outlined,
      'ri-restaurant-2-line': Icons.restaurant_outlined,
      'ri-hotel-bed-line': Icons.bed_outlined,
      'ri-sun-line': Icons.beach_access_outlined,
      'ri-calendar-event-line': Icons.event_outlined,
      'ri-alarm-line': Icons.alarm_outlined,
      'ri-bike-line': Icons.directions_bike_outlined,
      'ri-bus-line': Icons.directions_bus_outlined,
      'ri-hospital-line': Icons.local_hospital_outlined,
      'ri-lightbulb-line': Icons.lightbulb_outline,
      'ri-star-line': Icons.star_border,
      'ri-layout-grid-line': Icons.grid_view_rounded,
      'ri-puzzle-line': Icons.extension_outlined,
      'ri-brush-line': Icons.brush_outlined,
      'ri-car-line': Icons.drive_eta_outlined,
      'ri-gamepad-line': Icons.games_outlined,
      'ri-cake-3-line': Icons.emoji_food_beverage_outlined,
    };
    return map[key] ?? Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrickController>(
      builder: (controller) {
        final List<BrickModel> bricks = controller.bricks;

        return SizedBox(
          height: 30, // ✅ closer to your design screenshot (30px)
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              // ALL chip (empty set = show all)
              _FilterChip(
                icon: Icons.tune_rounded,
                label: 'All',
                color: const Color(0xFF9CA3AF),
                filled: activeIds.isEmpty,
                onTap: () => onChange(<String>{}),
              ),
              const SizedBox(width: 8),

              // Category chips from bricks
              ...bricks.map((b) {
                final chipColor =
                _hexToColor(b.color, fallback: const Color(0xFF3AA1FF));
                final filled = activeIds.contains(b.id);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    icon: _iconFromKey(b.icon),
                    label: b.name,
                    color: chipColor,
                    filled: filled,
                    onTap: () {
                      final updated = Set<String>.from(activeIds);

                      // If "All" is active (empty), start with this one
                      if (updated.isEmpty) {
                        updated.add(b.id);
                        onChange(updated);
                        return;
                      }

                      if (updated.contains(b.id)) {
                        updated.remove(b.id);
                      } else {
                        updated.add(b.id);
                      }

                      // If none selected => back to "All"
                      onChange(updated.isEmpty ? <String>{} : updated);
                    },
                  ),
                );
              }),

              // ✅ "+" button at end (restored)
              if (showAddButton) _AddCircleButton(onTap: onAddPressed),
            ],
          ),
        );
      },
    );
  }
}

/// ✅ Your original chip look: pill, icon + text, filled/unfilled
class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = filled ? color : Colors.white;
    final borderColor = filled ? color : color.withOpacity(0.35);
    final contentColor = filled ? Colors.white : color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: contentColor), // ✅ icon visible now
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ "+" button (same row, end)
class _AddCircleButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddCircleButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFE1E3EC);
    const iconColor = Color(0xFFB8BBC5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 1),
        ),
        child: const Icon(Icons.add, size: 18, color: iconColor),
      ),
    );
  }
}















