import 'package:flutter/material.dart';

import '../../../home/presentation/screens/home.dart';

class CategoryFilterBar extends StatelessWidget {
  final Set<EventCategory> active;
  final ValueChanged<Set<EventCategory>> onChange;

  const CategoryFilterBar({
    required this.active,
    required this.onChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final allSelected = active.length == EventCategory.values.length;

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
              if (!allSelected) {
                onChange(EventCategory.values.toSet());
              }
            },
          ),
          const SizedBox(width: 8),

          // Individual category chips
          ...EventCategory.values.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              icon: cat.icon,
              label: cat.label,
              color: cat.color,
              filled: active.contains(cat),
              onTap: () {
                final updated = Set<EventCategory>.from(active);
                if (updated.contains(cat)) {
                  updated.remove(cat);
                } else {
                  updated.add(cat);
                }

                // Avoid empty state (you can remove this if you want to allow none)
                if (updated.isEmpty) return;

                onChange(updated);
              },
            ),
          )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
    super.key,
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
