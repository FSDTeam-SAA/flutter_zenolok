import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import '../../../home/presentation/widgets/date_time_widget.dart';

class TodoDetailsDialog extends StatefulWidget {
  final String todoTitle;
  final String categoryTitle;
  final Color categoryColor;

  const TodoDetailsDialog({
    super.key,
    required this.todoTitle,
    required this.categoryTitle,
    required this.categoryColor,
  });

  @override
  State<TodoDetailsDialog> createState() => _TodoDetailsDialogState();
}

class _TodoDetailsDialogState extends State<TodoDetailsDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _hasDate = false;
  bool _hasTime = false;
  bool _hasAlarm = false;
  bool _hasRepeat = false;
  String _selectedAlarmOption = 'No alert';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  Future<void> _pickDate() async {
    final result = await showModalBottomSheet<DateRangeResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateRangeBottomSheet(
        initialStart: _selectedDate,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDate = result.start;
      });
    }
  }

  Future<void> _pickTime() async {
    final result = await showModalBottomSheet<TimeRangeResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TimeRangeBottomSheet(
        initialStart: _selectedTime,
        initialEnd: _selectedTime,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedTime = result.start;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  Future<void> _selectAlarm() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 120),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Blurred dark background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.white.withOpacity(0.0)),
              ),
            ),
            // Main dialog container
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.chevron_left,
                            size: 24,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Select Alarm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Alarm options
                  _AlarmOption(
                    title: 'No alert',
                    isSelected: _selectedAlarmOption == 'No alert',
                    onTap: () => Navigator.pop(context, 'No alert'),
                  ),
                  _AlarmOption(
                    title: 'Preset 1',
                    isSelected: _selectedAlarmOption == 'Preset 1',
                    onTap: () => Navigator.pop(context, 'Preset 1'),
                  ),
                  _AlarmOption(
                    title: 'Preset 2',
                    isSelected: _selectedAlarmOption == 'Preset 2',
                    onTap: () => Navigator.pop(context, 'Preset 2'),
                  ),
                  _AlarmOption(
                    title: 'Preset 3',
                    isSelected: _selectedAlarmOption == 'Preset 3',
                    onTap: () => Navigator.pop(context, 'Preset 3'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedAlarmOption = result;
        _hasAlarm = result != 'No alert';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenHeight * 0.25,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Blurred dark background
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.0)),
              ),
            ),
          ),
          // Header positioned ABOVE the dialog
          Positioned(
            left: 0,
            top: -30,
            child: Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                widget.categoryTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: widget.categoryColor,
                ),
              ),
            ),
          ),
          // Main dialog container
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(35),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top section - Back arrow, sliders icon, and todo title
                Container(
                  color: const Color(0xFFF6F6F6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.chevron_left,
                          size: 24,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(AppImages.sliders, width: 20, height: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.todoTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Options list - scrollable with gray background
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Date option
                      GestureDetector(
                        onTap: _hasDate ? _pickDate : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                AppImages.iconschedule,
                                width: 25,
                                height: 25,
                                color: _hasDate ? Colors.black87 : Colors.grey.shade400,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    if (_hasDate)
                                      Text(
                                        _formatDate(_selectedDate),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              CustomSwitch(
                                value: _hasDate,
                                onChanged: (v) => setState(() => _hasDate = v),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Time option
                      GestureDetector(
                        onTap: _hasTime ? _pickTime : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                AppImages.time,
                                width: 25,
                                height: 25,
                                color: _hasTime ? Colors.black87 : Colors.grey.shade400,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Time',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    if (_hasTime)
                                      Text(
                                        _formatTime(_selectedTime),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              CustomSwitch(
                                value: _hasTime,
                                onChanged: (v) => setState(() => _hasTime = v),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Alarm option
                      GestureDetector(
                        onTap: _selectAlarm,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                AppImages.notification2,
                                width: 25,
                                height: 25,
                                color: _hasAlarm ? Colors.black87 : Colors.grey.shade400,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _hasAlarm ? _selectedAlarmOption : 'Alarm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _hasAlarm ? FontWeight.w600 : FontWeight.w400,
                                    color: _hasAlarm ? Colors.black87 : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              // Icon(
                              //   Icons.chevron_right,
                              //   size: 20,
                              //   color: Colors.grey.shade400,
                              // ),
                            ],
                          ),
                        ),
                      ),

                      // Repeat option
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppImages.repeat,
                              width: 25,
                              height: 25,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Repeat',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            // CustomSwitch(
                            //   value: _hasRepeat,
                            //   onChanged: (v) => setState(() => _hasRepeat = v),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer - Done button
                Container(
                  color: const Color(0xFFF6F6F6),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: value ? const Color(0xFF34C759) : Colors.grey.shade300,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 39, // thumb width
            height: 24, // thumb height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100), // radius
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlarmOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlarmOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF34C759), width: 2)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF34C759),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
