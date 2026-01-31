import 'package:flutter/material.dart';

import '../../data/models/brick_model.dart';
import '../../data/models/calendar_event.dart';

class CalendarHelpers {
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool betweenIncl(DateTime x, DateTime a, DateTime b) {
    final dx = dateOnly(x), da = dateOnly(a), db = dateOnly(b);
    return (dx.isAtSameMomentAs(da) || dx.isAfter(da)) &&
        (dx.isAtSameMomentAs(db) || dx.isBefore(db));
  }

  static bool isMultiDayAllDay(CalendarEvent e) {
    if (!e.allDay || e.end == null) return false;
    final s = dateOnly(e.start);
    final en = dateOnly(e.end!);
    return !s.isAtSameMomentAs(en);
  }

  static Color hexToColor(String hex, {Color fallback = const Color(0xFF3AA1FF)}) {
    final raw = hex.replaceAll('#', '').trim();
    try {
      if (raw.length == 6) return Color(int.parse('FF$raw', radix: 16));
      if (raw.length == 8) return Color(int.parse(raw, radix: 16));
    } catch (_) {}
    return fallback;
  }

  static BrickModel? brickById(List<BrickModel> bricks, String id) {
    for (final b in bricks) {
      if (b.id == id) return b;
    }
    return null;
  }

  static Color eventColor(List<BrickModel> bricks, CalendarEvent e) {
    final b = brickById(bricks, e.categoryId);
    if (b == null) return const Color(0xFF3AA1FF);
    return hexToColor(b.color, fallback: const Color(0xFF3AA1FF));
  }

  static Map<String, IconData> getIconMap() {
    return {
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
  }

  static IconData getIconFromKey(String? key) {
    if (key == null || key.isEmpty) return Icons.widgets_outlined;
    return getIconMap()[key] ?? Icons.widgets_outlined;
  }
}
