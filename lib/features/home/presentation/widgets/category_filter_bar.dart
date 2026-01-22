import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/brick_model.dart';
import '../controller/brick_controller.dart';

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

  // iconKey -> IconData (matches API icon keys)
  IconData _iconFromKey(String key) {
    const map = <String, IconData>{
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
      'ghost_like': Icons.sentiment_very_satisfied_outlined,
      'balloon_like': Icons.celebration_outlined,
      'palette': Icons.palette_outlined,
      'cards': Icons.style_outlined,
      'game': Icons.sports_esports_outlined,
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
      'bank': Icons.account_balance_outlined,
      'tent': Icons.holiday_village_outlined,
      'store': Icons.storefront_outlined,
      'train': Icons.train_outlined,
      'tram': Icons.tram_outlined,
      'car': Icons.directions_car_outlined,
      'truck': Icons.local_shipping_outlined,
      'plane': Icons.flight_outlined,
      'rocket': Icons.rocket_launch_outlined,
      'lab': Icons.science_outlined,
      'food': Icons.restaurant_outlined,
      'coffee': Icons.local_cafe_outlined,
      'gym': Icons.fitness_center_outlined,
      'football': Icons.sports_soccer_outlined,
      'beach': Icons.beach_access_outlined,
      'hospital': Icons.local_hospital_outlined,
      'idea': Icons.lightbulb_outline,
      'puzzle': Icons.extension_outlined,
      'brush': Icons.brush_outlined,
      'pen': Icons.edit_outlined,
      'color': Icons.color_lens_outlined,
      'clean': Icons.cleaning_services_outlined,
      'lock': Icons.lock_outline,
      'security': Icons.security_outlined,
      'globe': Icons.language_outlined,
      'map': Icons.map_outlined,
      'pin': Icons.location_on_outlined,
      'card': Icons.credit_card_outlined,
      'money': Icons.attach_money,
      'savings': Icons.savings_outlined,
      'bag': Icons.shopping_bag_outlined,
      'mall': Icons.local_mall_outlined,
      'list': Icons.list_alt_outlined,
      'task': Icons.task_alt_outlined,
      'chat': Icons.chat_bubble_outline,
      'forum': Icons.forum_outlined,
      'mail': Icons.mail_outline,
      'share': Icons.share_outlined,
      'link': Icons.link_outlined,
      'group': Icons.group_outlined,
      'handshake': Icons.handshake_outlined,
      'public': Icons.public_outlined,
    };
    return map[key] ?? Icons.widgets_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrickController>(
      builder: (controller) {
        final List<BrickModel> bricks = controller.bricks;

        return SizedBox(
          height: 28, // closer to design
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              // ALL chip (empty set = show all)
              _FilterChip(
                icon: Icons.manage_search,
                label: 'All',
                color: const Color(0xFFB6B5B5), //  CHANGE HERE (was 0xFF9CA3AF)
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
                      if (activeIds.contains(b.id)) {
                        onChange(<String>{});      // back to "All"
                      } else {
                        onChange(<String>{b.id});  // select ONLY this one
                      }
                    },


                  ),
                );
              }),

              // "+" button at end
              if (showAddButton) _AddCircleButton(onTap: onAddPressed),
            ],
          ),
        );
      },
    );
  }
}

/// Chip: pill, icon + text, filled/unfilled
class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled; // <-- this means SELECTED (active)
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
    //  SELECTED => outline (like screenshot)
    //  NOT selected => filled color + white text
    final bgColor = filled ? Colors.white : color;
    final borderColor = color; // keep border always same color
    final contentColor = filled ? color : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.baseline, 
          textBaseline: TextBaseline.alphabetic,           // required
          children: [
            Transform.translate(
              offset: const Offset(0, 0), // change to 0.5 if needed
              child: Icon(icon, size: 15, color: contentColor),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.dongle(
                fontWeight: FontWeight.w400,
                fontSize: 22,
                height: 18/22,
                letterSpacing: 0,
                color: contentColor,
              ),
            ),
          ],
        )

      ),
    );
  }
}



/// "+" button (same row, end)
class _AddCircleButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddCircleButton({this.onTap});

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


