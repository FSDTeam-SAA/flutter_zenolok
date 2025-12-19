import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/data/models/brick_model.dart';
import '../../../home/presentation/controller/brick_controller.dart';


typedef CategoryFilterChanged = void Function(Set<String> activeIds);

class CategoryFilterBar extends StatelessWidget {
  final Set<String> activeIds;
  final CategoryFilterChanged onChange;

  const CategoryFilterBar({
    super.key,
    required this.activeIds,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final BrickController controller = Get.find<BrickController>();

    return Obx(() {
      final List<BrickModel> bricks = controller.bricks;

      // "All" is considered selected when:
      // - no filter is set (empty => show all)
      // - OR user selected every brick id
      final allSelected = activeIds.isEmpty ||
          (bricks.isNotEmpty && activeIds.length == bricks.length);

      return SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          children: [
            // 'All' Chip
            _FilterChip(
              icon: Icons.tune_rounded,
              label: 'All',
              color: const Color(0xFF9CA3AF),
              filled: allSelected,
              onTap: () {
                // back to "All" state => clear filters
                if (!allSelected) onChange(<String>{});
              },
            ),
            const SizedBox(width: 8),

            // Individual brick chips
            ...bricks.map((b) {
              final chipColor = _hexToColor(b.color);
              final isFilled = activeIds.isNotEmpty && activeIds.contains(b.id);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  icon: _iconFromKey(b.icon),
                  label: b.name,
                  color: chipColor,
                  filled: isFilled,
                  onTap: () {
                    final updated = Set<String>.from(activeIds);

                    // if we are currently in "All" state (empty), start a selection set
                    if (updated.contains(b.id)) {
                      updated.remove(b.id);
                    } else {
                      updated.add(b.id);
                    }

                    // If user removed everything, go back to "All" (empty set)
                    if (updated.isEmpty) {
                      onChange(<String>{});
                      return;
                    }

                    // Optional: if user selected all ids, you can also clear to "All"
                    // (keeps behavior consistent + simpler state)
                    if (updated.length == bricks.length) {
                      onChange(<String>{});
                      return;
                    }

                    onChange(updated);
                  },
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _FilterChip({
    super.key,
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
      ),
    );
  }
}

/// "#RRGGBB" or "#AARRGGBB" -> Color (fallback gray)
Color _hexToColor(String? hex, {Color fallback = const Color(0xFF9CA3AF)}) {
  if (hex == null) return fallback;
  final raw = hex.replaceAll('#', '').trim();
  try {
    if (raw.length == 6) return Color(int.parse('FF$raw', radix: 16));
    if (raw.length == 8) return Color(int.parse(raw, radix: 16));
  } catch (_) {}
  return fallback;
}

/// Maps your stored iconKey (from CategoryEditorWidget) -> IconData
IconData _iconFromKey(String? key) {
  if (key == null) return Icons.work_outline;

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
    'ri-layout-grid-line': Icons.workspaces_outline,
    'ri-puzzle-line': Icons.extension_outlined,
    'ri-brush-line': Icons.brush_outlined,
    'ri-car-line': Icons.drive_eta_outlined,
    'ri-gamepad-line': Icons.games_outlined,
    'ri-cake-3-line': Icons.emoji_food_beverage_outlined,
  };

  return map[key] ?? Icons.work_outline;
}
