import 'package:flutter/material.dart';

class ScheduledDialog extends StatefulWidget {
  const ScheduledDialog({super.key});

  @override
  State<ScheduledDialog> createState() => _ScheduledDialogState();
}

class _ScheduledDialogState extends State<ScheduledDialog> {
  String _selectedTab = 'Unfinished';
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _todos = [
    {
      'title': 'Pay rent',
      'checked': false,
      'category': 'Bills',
      'time': '-1 hour',
      'isOverdue': true,
      'color': const Color(0xFF4A9FF5),
    },
    {
      'title': 'History assignment',
      'checked': false,
      'category': 'Homework',
      'time': '-4 hours',
      'isOverdue': true,
      'color': const Color(0xFFF9A826),
    },
    {
      'title': 'Fill a form',
      'checked': false,
      'category': 'Homework',
      'time': '8 days',
      'isOverdue': false,
      'color': const Color(0xFFF9A826),
    },
    {
      'title': 'Yogurt',
      'checked': false,
      'category': 'Groceries',
      'time': '12 days',
      'isOverdue': false,
      'color': const Color(0xFF4A9FF5),
    },
    {
      'title': 'Turkey',
      'checked': false,
      'category': 'Groceries',
      'time': '17 days',
      'isOverdue': false,
      'color': const Color(0xFFF9A826),
    },
    {
      'title': 'Electricity bill',
      'checked': false,
      'category': 'Bills',
      'time': '19 days',
      'isOverdue': false,
      'color': const Color(0xFF4A9FF5),
    },
    {
      'title': 'Water bill',
      'checked': false,
      'category': 'Bills',
      'time': '200 days',
      'isOverdue': false,
      'color': const Color(0xFF4A9FF5),
    },
    {
      'title': 'Insurance fee',
      'checked': false,
      'category': 'Bills',
      'time': '201 days',
      'isOverdue': false,
      'color': const Color(0xFF4A9FF5),
    },
    {
      'title': 'Car insurance',
      'checked': false,
      'category': 'Bills',
      'time': '300 days',
      'isOverdue': false,
      'color': const Color(0xFF4A9FF5),
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'color': Colors.grey},
    {'name': 'Bills', 'color': const Color(0xFF4A9FF5)},
    {'name': 'Groceries', 'color': const Color(0xFFF9844A)},
    {'name': 'Homework', 'color': const Color(0xFFF9A826)},
    {'name': 'Gym', 'color': const Color(0xFF9C27B0)},
    {'name': 'Routine', 'color': const Color(0xFFFF9800)},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.1,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Scheduled',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      size: 24,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  _buildTab('Unfinished'),
                  const SizedBox(width: 24),
                  _buildTab('Finished'),
                  const SizedBox(width: 24),
                  _buildTab('All'),
                  const Spacer(),
                  const Icon(
                    Icons.filter_list,
                    size: 22,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),

            // Category chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 20, bottom: 16),
              child: SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category['name'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category['name'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? category['color']
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? category['color']
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            category['name'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Todo list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Time label
                        SizedBox(
                          width: 60,
                          child: Text(
                            todo['time'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: todo['isOverdue']
                                  ? Colors.red
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Checkbox circle
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _todos[index]['checked'] =
                                  !_todos[index]['checked'];
                            });
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: todo['color'],
                                width: 2.5,
                              ),
                              color: todo['checked']
                                  ? todo['color']
                                  : Colors.transparent,
                            ),
                            child: todo['checked']
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
                            todo['title'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: todo['checked']
                                  ? Colors.grey
                                  : Colors.black87,
                              decoration: todo['checked']
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        // Icons on the right
                        Icon(
                          Icons.notifications_none,
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.drag_indicator,
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.black87 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(height: 2, width: 40, color: Colors.black87),
        ],
      ),
    );
  }
}
