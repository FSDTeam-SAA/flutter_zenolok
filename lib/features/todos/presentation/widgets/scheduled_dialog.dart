import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import '../controllers/event_totos_controller.dart';

class ScheduledDialog extends GetView<EventTodosController> {
  const ScheduledDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.15,
      ),
      child: _ScheduledDialogContent(
        screenHeight: screenHeight,
        screenWidth: screenWidth,
      ),
    );
  }
}

class _ScheduledDialogContent extends GetView<EventTodosController> {
  final double screenHeight;
  final double screenWidth;

  const _ScheduledDialogContent({
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        final selectedTab = ValueNotifier<String>('Unfinished');
        final selectedCategory = ValueNotifier<String>('All');

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Blurred dark background
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.0),
                  ),
                ),
              ),
            ),
            // Header positioned ABOVE the dialog
            Positioned(
              left: 0,
              top: -30,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    Image.asset(
                      AppImages.iconschedule,
                      width: 17,
                      height: 17,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 3),
                    const Text(
                      'Scheduled',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main dialog container
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(35),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // White container for tabs and category chips with rounded top corners
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tabs section
                        Container(
                          color: const Color(0xFFF5F5F7),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 38,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              ValueListenableBuilder<String>(
                                valueListenable: selectedTab,
                                builder: (context, tab, _) => Row(
                                  children: [
                                    _buildTab('Unfinished', tab, selectedTab, setState),
                                    const SizedBox(width: 24),
                                    _buildTab('Finished', tab, selectedTab, setState),
                                    const SizedBox(width: 24),
                                    _buildTab('All', tab, selectedTab, setState),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Image.asset(
                                AppImages.schedulefilter,
                                width: 16,
                                height: 16,
                              ),
                            ],
                          ),
                        ),

                        // Category chips (smaller, responsive)
                        Container(
                          color: const Color(0xFFF5F5F7),
                          padding: const EdgeInsets.only(left: 16, bottom: 12),
                          child: SizedBox(
                            height: 25,
                            child: ValueListenableBuilder<String>(
                              valueListenable: selectedCategory,
                              builder: (context, category, _) {
                                final categories = controller.getScheduledCategories();
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categories.length,
                                  itemBuilder: (context, index) {
                                    final categoryName = categories[index];
                                    final isSelected = selectedCategory.value == categoryName;
                                    final categoryColor = categoryName == 'All'
                                        ? Colors.grey
                                        : _parseColorFromHex(
                                            controller.getCategoryColor(categoryName));

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          selectedCategory.value = categoryName;
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? categoryColor
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            border: Border.all(
                                              color: isSelected
                                                  ? categoryColor
                                                  : Colors.grey.shade300,
                                              width: isSelected ? 1.4 : 1.0,
                                            ),
                                          ),
                                          child: Text(
                                            categoryName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Todo list with gray background
                  Flexible(
                    child: ValueListenableBuilder<String>(
                      valueListenable: selectedTab,
                      builder: (context, tab, _) =>
                          ValueListenableBuilder<String>(
                        valueListenable: selectedCategory,
                        builder: (context, category, _) {
                          final filteredTodos = controller
                              .getFilteredScheduledTodos(
                                categoryFilter: category,
                                statusFilter: tab,
                              );

                          return Obx(
                            () {
                              if (controller.isLoadingScheduled.value) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (filteredTodos.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No $tab todos',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                itemCount: filteredTodos.length,
                                itemBuilder: (context, index) {
                                  final todo = filteredTodos[index];
                                  final categoryColor = todo.categoryId?.color != null
                                      ? _parseColorFromHex(
                                          todo.categoryId!.color)
                                      : Colors.grey;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Time label
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            todo.sectionLabel,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Checkbox circle
                                        GestureDetector(
                                          onTap: () {
                                            // TODO: Implement toggle completion
                                          },
                                          child: Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: categoryColor,
                                                width: 2.5,
                                              ),
                                              color: todo.isCompleted
                                                  ? categoryColor
                                                  : Colors.transparent,
                                            ),
                                            child: todo.isCompleted
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 14,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Todo title
                                        Expanded(
                                          child: Text(
                                            todo.text,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: todo.isCompleted
                                                  ? Colors.grey
                                                  : Colors.black87,
                                              decoration: todo.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        // Icons on the right
                                        Image.asset(
                                          AppImages.notification2,
                                          width: 20,
                                          height: 20,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(width: 10),
                                        Image.asset(
                                          AppImages.repeat,
                                          width: 20,
                                          height: 20,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(width: 10),
                                        Image.asset(
                                          AppImages.sliders,
                                          width: 20,
                                          height: 20,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTab(String title, String currentTab,
      ValueNotifier<String> tabNotifier, Function(VoidCallback) setState) {
    final isSelected = currentTab == title;
    return GestureDetector(
      onTap: () {
        tabNotifier.value = title;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color:
                  isSelected ? Colors.black87 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 2,
              width: 40,
              color: Colors.black87,
            ),
        ],
      ),
    );
  }

  Color _parseColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.grey;
    }
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('0xFF$hex'));
    } catch (e) {
      return Colors.grey;
    }
  }
}
