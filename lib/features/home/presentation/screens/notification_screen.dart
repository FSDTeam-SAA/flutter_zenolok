import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // simple in-memory data model
  final List<_NotificationItem> _items = [
    _NotificationItem(type: _NotificationType.messages, isRead: false),
    _NotificationItem(type: _NotificationType.system, isRead: false),
    _NotificationItem(type: _NotificationType.messages, isRead: true),
  ];

  bool _showUnreadOnly = true; // when false -> "read view" (All)

  int _unreadCountFor(_NotificationType type) =>
      _items.where((n) => n.type == type && !n.isRead).length;

  int get _unreadAll =>
      _items.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    // what to display depending on mode
    final visibleItems = _showUnreadOnly
        ? _items.where((n) => !n.isRead).toList()
        : _items;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top bar: back + "Unread" (tap to toggle Unread / All)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,color:Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() => _showUnreadOnly = !_showUnreadOnly);
                    },
                    child: Text(
                      _showUnreadOnly ? 'Unread' : 'All',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D8CFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs row: Messages / System / All with dynamic badges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TabWithBadge(
                    label: 'Messages',
                    count: _unreadCountFor(_NotificationType.messages),
                    isSelected: false,
                  ),
                  _TabWithBadge(
                    label: 'System',
                    count: _unreadCountFor(_NotificationType.system),
                    isSelected: false,
                  ),
                  _TabWithBadge(
                    label: 'All',
                    count: _unreadAll,
                    isSelected: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notification list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  for (int i = 0; i < visibleItems.length; i++) ...[
                    _NotificationRow(
                      isRead: visibleItems[i].isRead,
                      onToggleRead: () {
                        setState(() {
                          // flip the flag in the original list
                          visibleItems[i].isRead = !visibleItems[i].isRead;
                        });
                      },
                    ),
                    if (i != visibleItems.length - 1)
                      const SizedBox(height: 16),
                  ],
                  if (visibleItems.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text('No notifications'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// SMALL HELPERS
/// ---------------------------------------------------------------------------

enum _NotificationType { messages, system }

class _NotificationItem {
  _NotificationItem({
    required this.type,
    this.isRead = false,
  });

  final _NotificationType type;
  bool isRead;
}

class _TabWithBadge extends StatelessWidget {
  const _TabWithBadge({
    required this.label,
    required this.count,
    this.isSelected = false,
  });

  final String label;
  final int count;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
            if (count > 0)
              Positioned(
                top: -8,
                right: -12,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.isRead,
    required this.onToggleRead,
  });

  final bool isRead;
  final VoidCallback onToggleRead;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // left circle: filled when read, outline when unread
        InkWell(
          onTap: onToggleRead,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRead ? const Color(0xFFE5E5E5) : Colors.transparent,
              border: Border.all(
                color: isRead ? Colors.transparent : Colors.black26,
                width: 1.3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // rounded card: slightly different shade when read
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: isRead ? const Color(0xFFF9F9F9) : const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
    );
  }
}
