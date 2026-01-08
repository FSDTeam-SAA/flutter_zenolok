import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'package:get/get.dart';
import '../controllers/event_totos_controller.dart';
import 'scheduled_dialog.dart';

class ScheduledSection extends GetView<EventTodosController> {
  const ScheduledSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                Image.asset(AppImages.iconschedule, width: 17, height: 17),
                const SizedBox(width: 3),
                Text(
                  'Scheduled',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A4A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${controller.scheduledTodos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
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
          child: Obx(
            () {
              if (controller.isLoadingScheduled.value) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: const Center(
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              if (controller.scheduledTodos.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: const Center(
                    child: Text(
                      'No scheduled todos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }

              // Show up to 3 items
              final itemsToShow = controller.scheduledTodos.take(3).toList();
              final remainingCount = controller.scheduledTodos.length - itemsToShow.length;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Column(
                  children: [
                    ...itemsToShow.asMap().entries.map((entry) {
                      final index = entry.key;
                      final todo = entry.value;
                      final dotColor = todo.categoryId?.color != null
                          ? Color(int.parse('0xFF${todo.categoryId!.color.replaceFirst('#', '')}'))
                          : const Color(0xFF4A4A4A);

                      return Padding(
                        padding: EdgeInsets.only(bottom: index < itemsToShow.length - 1 ? 10 : 0),
                        child: _ScheduledTodoRow(
                          timeLabel: todo.sectionLabel,
                          timeColor: Colors.grey,
                          dotColor: dotColor,
                          title: todo.text,
                          categoryName: todo.categoryId?.name,
                        ),
                      );
                    }),
                    if (remainingCount > 0) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 80),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '+$remainingCount',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
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
  final String? categoryName;

  const _ScheduledTodoRow({
    required this.timeLabel,
    required this.timeColor,
    required this.dotColor,
    required this.title,
    this.categoryName,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        _ColoredRing(color: dotColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (categoryName != null)
                Text(
                  categoryName!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
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
