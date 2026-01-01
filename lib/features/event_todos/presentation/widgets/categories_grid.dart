import 'package:flutter/material.dart';
import 'category_dialog.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1
        Row(
          children: [
            Expanded(
              child: _CategoryCard(
                title: 'Routine',
                titleColor: Colors.orange,
                todos: ['Mop floor', 'Clean the bathr...'],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => CategoryDialog(
                      categoryTitle: 'Groceries',
                      categoryColor: Colors.deepOrange,
                      initialTodos: ['Yogurt', 'Ice cream', 'Turkey', 'Bread'],
                    ),
                  );
                },
                child: _CategoryCard(
                  title: 'Groceries',
                  titleColor: Colors.deepOrange,
                  todos: ['Yogurt', 'Ice cream', 'Turkey'],
                  showMoreCount: '+1',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Row 2
        Row(
          children: [
            Expanded(
              child: _CategoryCard(
                title: 'Gym',
                titleColor: Colors.purple,
                todos: ['10 push ups', '20 sit ups'],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _CategoryCard(
                title: 'Homework',
                titleColor: Color(0xFFF4A300),
                todos: ['History assignm...', 'Fill a form'],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Row 3
        Row(
          children: [
            Expanded(
              child: _CategoryCard(
                title: 'Bills',
                titleColor: Colors.lightBlue,
                todos: ['Pay rent', 'Water bill'],
              ),
            ),
            SizedBox(width: 12),
            Expanded(child: _AddCategoryCard()),
          ],
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<String> todos;
  final String? showMoreCount;

  const _CategoryCard({
    required this.title,
    required this.titleColor,
    required this.todos,
    this.showMoreCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title outside the card (top)
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ),
        const SizedBox(height: 6),

        /// Actual card
        Container(
          height: 140, // Fixed height for all cards (adjust as needed)
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(35),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...todos.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const _TodoCircle(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4A4A4A),
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (showMoreCount != null) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      showMoreCount!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 4),
                const Text(
                  'New todo',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD0D0D0),
                    fontWeight: FontWeight.w400,
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

class _TodoCircle extends StatelessWidget {
  const _TodoCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD0D0D0), width: 1.5),
      ),
    );
  }
}

class _AddCategoryCard extends StatelessWidget {
  const _AddCategoryCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20), // title nai, tai thora gap
        const SizedBox(height: 140, child: _DashedAddBox()),
      ],
    );
  }
}

/// Optional: just normal border; jodi dashed chai alada painter লাগবে
class _DashedAddBox extends StatelessWidget {
  const _DashedAddBox();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFFE0E0E0),
            strokeWidth: 1.5,
            radius: 30,
            dashLength: 8,
            dashGap: 6,
          ),
          child: const Center(child: Icon(Icons.add, size: 28, color: Colors.grey)),
        );
      },
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double dashGap;

  const _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 22,
    this.dashLength = 8,
    this.dashGap = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(strokeWidth / 2), Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double start = distance;
        final double end = (distance + dashLength).clamp(0, metric.length);
        final dashPath = metric.extractPath(start, end);
        canvas.drawPath(dashPath, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
