import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/brick_model.dart';
import '../bindings/brick_binding.dart';
import 'cateogry_widget.dart';


typedef BrickFilterChanged = void Function(Set<String> activeBrickIds);

class BrickFilterBar extends StatelessWidget {
  const BrickFilterBar({
    super.key,
    required this.bricks,
    required this.activeIds,
    required this.onChange,
  });

  final List<BrickModel> bricks;
  final Set<String> activeIds;
  final BrickFilterChanged onChange;

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length != 6) return const Color(0xFFBFC1C8);
    return Color(int.parse('FF$h', radix: 16));
    // FF = alpha
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 21;

    final allOn = bricks.isNotEmpty && activeIds.length == bricks.length;

    Widget chip({
      required Widget child,
      required bool selected,
      required VoidCallback onTap,
      Color? bg,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: barHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? (bg ?? const Color(0xFFEFF3F9)) : const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withValues(alpha: .06)),
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
            child: child,
          ),
        ),
      );
    }

    Widget plusCircle() {
      return GestureDetector(
        onTap: () async {
          // ✅ open editor with binding so controller exists
          final BrickModel? created = await Get.to<BrickModel>(
                () => const CategoryEditorScreen(),
            binding: BrickBinding(),
          );

          if (created != null) {
            // ✅ auto-select new brick (or keep “all”)
            if (allOn) {
              onChange(bricks.map((b) => b.id).toSet()..add(created.id));
            } else {
              onChange({...activeIds, created.id});
            }
          }
        },
        child: Container(
          width: barHeight,
          height: barHeight,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFFBFC1C8), width: 1.4),
          ),
          child: const Center(
            child: Icon(Icons.add, size: 18, color: Color(0xFFBFC1C8)),
          ),
        ),
      );
    }

    return SizedBox(
      height: barHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // ALL
            chip(
              selected: allOn,
              onTap: () => onChange(bricks.map((b) => b.id).toSet()),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(Icons.mail_outline_rounded, size: 12, color: Color(0xFF7F8392)),
                  ),
                  const SizedBox(width: 6),
                  const Text('All'),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Bricks chips
            for (final b in bricks) ...[
              chip(
                bg: _hexToColor(b.color).withValues(alpha: .15),
                selected: activeIds.contains(b.id),
                onTap: () {
                  final next = {...activeIds};
                  if (next.contains(b.id)) {
                    next.remove(b.id);
                    if (next.isEmpty) next.add(b.id); // keep at least one
                  } else {
                    next.add(b.id);
                  }
                  onChange(next);
                },
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                      child: Icon(Icons.work_outline, size: 14, color: _hexToColor(b.color)), // you can map iconKey later
                    ),
                    const SizedBox(width: 6),
                    Text(b.name),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],

            plusCircle(),
          ],
        ),
      ),
    );
  }
}
