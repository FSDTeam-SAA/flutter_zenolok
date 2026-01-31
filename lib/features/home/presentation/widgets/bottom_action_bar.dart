import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'package:flutter_zenolok/features/home/presentation/widgets/flat_plus_button.dart';
import 'package:flutter_zenolok/features/home/presentation/widgets/ghost_pill.dart';
import '../../data/models/calendar_event.dart';

class BottomActionBar extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTodayTap;
  final Function(CalendarEvent) onAddEvent;

  const BottomActionBar({
    super.key,
    required this.selectedDate,
    required this.onTodayTap,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Spacer(),
          GhostPill(
            label: 'TODAY',
            iconPath: AppImages.today_back_icon,
            onTap: onTodayTap,
          ),
          const SizedBox(width: 10),
          FlatPlusButton(
            initialDate: selectedDate,
            onAdd: onAddEvent,
          ),
        ],
      ),
    );
  }
}
