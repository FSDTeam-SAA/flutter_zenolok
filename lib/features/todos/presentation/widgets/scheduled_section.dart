import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'scheduled_dialog.dart';

class ScheduledSection extends StatelessWidget {
  const ScheduledSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Row(
            children: [
              Image.asset(AppImages.iconschedule, width: 17, height: 17),
              SizedBox(width: 3),
              Text(
                'Scheduled',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const ScheduledDialog(),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Column(
              children: const [
                _ScheduledTodoRow(
                  timeLabel: '-1 hour',
                  timeColor: Colors.red,
                  dotColor: Color(0xFFF9C74F),
                  title: 'Yogurt',
                ),
                SizedBox(height: 10),
                _ScheduledTodoRow(
                  timeLabel: '4 days',
                  timeColor: Colors.grey,
                  dotColor: Color(0xFFF9844A),
                  title: 'History assignment',
                ),
                SizedBox(height: 10),
                _ScheduledTodoRow(
                  timeLabel: '8 days',
                  timeColor: Colors.grey,
                  dotColor: Color(0xFF43AA8B),
                  title: 'Pay rent',
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 80),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '+1',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduledTodoRow extends StatelessWidget {
  final String timeLabel;
  final Color timeColor;
  final Color dotColor;
  final String title;

  const _ScheduledTodoRow({
    required this.timeLabel,
    required this.timeColor,
    required this.dotColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            timeLabel,
            style: TextStyle(
              fontSize: 11,
              color: timeColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 4),
        _ColoredRing(color: dotColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ColoredRing extends StatelessWidget {
  final Color color;

  const _ColoredRing({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}
