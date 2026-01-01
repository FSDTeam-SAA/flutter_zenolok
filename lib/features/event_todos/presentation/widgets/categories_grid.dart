import 'package:flutter/material.dart';
import 'category_dialog.dart';

class CategoriesGrid extends StatefulWidget {
  const CategoriesGrid({super.key});

  @override
  State<CategoriesGrid> createState() => _CategoriesGridState();
}

class _CategoriesGridState extends State<CategoriesGrid> {
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Routine',
      'color': Colors.orange,
      'todos': ['Mop floor', 'Clean the bathr...']
    },
    {
      'title': 'Groceries',
      'color': Colors.deepOrange,
      'todos': ['Yogurt', 'Ice cream', 'Turkey', 'Bread']
    },
    {
      'title': 'Gym',
      'color': Colors.purple,
      'todos': ['10 push ups', '20 sit ups']
    },
    {
      'title': 'Homework',
      'color': const Color(0xFFF4A300),
      'todos': ['History assignm...', 'Fill a form']
    },
    {
      'title': 'Bills',
      'color': Colors.lightBlue,
      'todos': ['Pay rent', 'Water bill']
    },
  ];

  void _openCategory(int index) {
    final cat = _categories[index];
    showDialog(
      context: context,
      builder: (context) => CategoryDialog(
        categoryTitle: cat['title'],
        categoryColor: cat['color'],
        initialTodos: List<String>.from(cat['todos']),
      ),
    );
  }

  Future<void> _openNewCategoryDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const NewCategoryDialog(),
    );

    if (result != null && result['title'] != null && result['color'] != null) {
      setState(() {
        _categories.add({
          'title': result['title'],
          'color': result['color'],
          'todos': <String>[],
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build rows of two cards each, final slot is add button
    final List<Widget> rows = [];
    final totalSlots = _categories.length + 1; // +1 for add card
    for (int i = 0; i < totalSlots; i += 2) {
      final leftIndex = i;
      final rightIndex = i + 1;

      Widget leftChild;
      if (leftIndex < _categories.length) {
        final c = _categories[leftIndex];
        leftChild = GestureDetector(
          onTap: () => _openCategory(leftIndex),
          child: _CategoryCard(
            title: c['title'],
            titleColor: c['color'],
            todos: List<String>.from(c['todos']),
            showMoreCount: null,
          ),
        );
      } else {
        leftChild = _AddCategoryCard(onTap: _openNewCategoryDialog);
      }

      Widget rightChild;
      if (rightIndex < _categories.length) {
        final c = _categories[rightIndex];
        rightChild = GestureDetector(
          onTap: () => _openCategory(rightIndex),
          child: _CategoryCard(
            title: c['title'],
            titleColor: c['color'],
            todos: List<String>.from(c['todos']),
          ),
        );
      } else if (rightIndex == _categories.length) {
        rightChild = _AddCategoryCard(onTap: _openNewCategoryDialog);
      } else {
        rightChild = const SizedBox.shrink();
      }

      rows.add(Row(
        children: [
          Expanded(child: leftChild),
          const SizedBox(width: 12),
          Expanded(child: rightChild),
        ],
      ));

      rows.add(const SizedBox(height: 12));
    }

    // Remove the trailing SizedBox
    if (rows.isNotEmpty) rows.removeLast();

    return Column(children: rows);
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
  final VoidCallback? onTap;

  const _AddCategoryCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20), // title gap
          const SizedBox(height: 140, child: _DashedAddBox()),
        ],
      ),
    );
  }
}

class NewCategoryDialog extends StatefulWidget {
  const NewCategoryDialog({super.key});

  @override
  State<NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  Color? _selectedColor;

  final List<Color> _palette = const [
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFFA78BFA),
    Color(0xFFB91C1C),
    Color(0xFF111827),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF0EA5A4),
    Color(0xFF34D399),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  void _onAdd() {
    if (_nameController.text.trim().isEmpty || _selectedColor == null) return;
    Navigator.of(context).pop({'title': _nameController.text.trim(), 'color': _selectedColor});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text(
              'New Category',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _palette
                  .map((c) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = c),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: _selectedColor == c ? Border.all(color: Colors.black26, width: 2) : null,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Category name',
                border: OutlineInputBorder(borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),
            if (_nameController.text.trim().isNotEmpty && _selectedColor != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _onAdd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox.shrink(),
            ],
          ],
        ),
      ),
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
