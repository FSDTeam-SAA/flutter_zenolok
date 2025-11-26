import 'package:flutter/material.dart';
import '../../../event/presentation/screens/event_screen.dart';
import '../screens/home.dart';           // for EventCategory + extension

typedef CategoryFilterChanged = void Function(Set<EventCategory>);

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.active,
    required this.onChange,
  });

  /// Currently selected categories
  final Set<EventCategory> active;

  /// Called whenever selection changes
  final CategoryFilterChanged onChange;

  @override
  Widget build(BuildContext context) {
    final allOn = active.length == EventCategory.values.length;
    const double barHeight = 21;

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
            color: selected
                ? (bg ?? const Color(0xFFEFF3F9))
                : const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(.06)),
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
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
              const CategoryEditorScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // from right to left
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                final tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        },
        child: Container(
          width: barHeight,
          height: barHeight,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFBFC1C8),
              width: 1.4,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.add,
              size: 18,
              color: Color(0xFFBFC1C8),
            ),
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
              onTap: () => onChange({...EventCategory.values}),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.mail_outline_rounded,
                      size: 12,
                      color: Color(0xFF7F8392),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('All'),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Category chips
            for (final c in EventCategory.values) ...[
              chip(
                bg: c.pastel,
                selected: active.contains(c),
                onTap: () {
                  final next = {...active};
                  if (next.contains(c)) {
                    next.remove(c);
                    if (next.isEmpty) next.add(c); // keep at least one
                  } else {
                    next.add(c);
                  }
                  onChange(next);
                },
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(c.icon, size: 14, color: c.color),
                    ),
                    const SizedBox(width: 6),
                    Text(c.label),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],

            // grey circular "+" button
            plusCircle(),
          ],
        ),
      ),
    );
  }
}
