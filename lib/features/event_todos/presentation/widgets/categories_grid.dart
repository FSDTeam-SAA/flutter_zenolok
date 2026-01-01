import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'category_details_dialog.dart';

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
      'todos': ['Mop floor', 'Clean the bathr...'],
    },
    {
      'title': 'Groceries',
      'color': Colors.deepOrange,
      'todos': ['Yogurt', 'Ice cream', 'Turkey', 'Bread'],
    },
    {
      'title': 'Gym',
      'color': Colors.purple,
      'todos': ['10 push ups', '20 sit ups'],
    },
    {
      'title': 'Homework',
      'color': const Color(0xFFF4A300),
      'todos': ['History assignm...', 'Fill a form'],
    },
    {
      'title': 'Bills',
      'color': Colors.lightBlue,
      'todos': ['Pay rent', 'Water bill'],
    },
  ];

  void _openCategory(int index) {
    final cat = _categories[index];
    showDialog(
      context: context,
      builder: (context) => CategoryDetailsDialog(
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

      rows.add(
        Row(
          children: [
            Expanded(child: leftChild),
            const SizedBox(width: 12),
            Expanded(child: rightChild),
          ],
        ),
      );

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
                    padding: const EdgeInsets.only(bottom: 2.0),
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
  bool _isEditingName = true;
  final FocusNode _focusNode = FocusNode();

  final List<Color> _palette = const [
    // Row 1 - Bright colors
    Color(0xFFFF383C), Color(0xFFFF8D28), Color(0xFFFFCC00), Color(0xFF34C759),
    Color(0xFF00C0E8), Color(0xFF0088FF), Color(0xFF6155F5), Color(0xFFCB30E0),
    Color(0xFFFF2D55), Color(0xFFAC7F5E),
    // Row 2 - Light/Pastel colors
    Color(0xFFFFC2BD), Color(0xFFFFD4AE), Color(0xFFFFF4C6), Color(0xFFE4F3E8),
    Color(0xFFCAEBF2), Color(0xFFE0EBF3), Color(0xFFEAE9F4), Color(0xFFF4E5F6),
    Color(0xFFFFE8EC), Color(0xFFEEE4DC),
    // Row 3 - Medium/Muted colors
    Color(0xFFC36062), Color(0xFFE6D6C8), Color(0xFFDFD5AD), Color(0xFFCCDED0),
    Color(0xFFABC3C8), Color(0xFFB3C1CD), Color(0xFFB3C1CD), Color(0xFFB8B6CA),
    Color(0xFFC8939D), Color(0xFFA69588),
    // Row 4 - Dark colors
    Color(0xFF9C2426), Color(0xFFBD7434), Color(0xFF72611E), Color(0xFF3F694A),
    Color(0xFF1E6372), Color(0xFF26537A), Color(0xFF514E73), Color(0xFF674B6B),
    Color(0xFF732D3A), Color(0xFF5B4230),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onAdd() {
    if (_nameController.text.trim().isEmpty || _selectedColor == null) return;
    Navigator.of(
      context,
    ).pop({'title': _nameController.text.trim(), 'color': _selectedColor});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = (screenWidth * 0.85).clamp(260.0, 420.0);
    final dialogHeight = (screenHeight * 0.40).clamp(320.0, 640.0);

    const horizontalPadding = 12.0;
    const circleSpacing = 0.0;
    const cols = 10;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: (screenWidth - dialogWidth) / 2,
        vertical: (screenHeight - dialogHeight) / 2,
      ),
      child: Center(
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.grey,
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: _isEditingName
                            ? SizedBox(
                                width: dialogWidth * 0.6,
                                child: TextField(
                                  controller: _nameController,
                                  focusNode: _focusNode,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedColor ?? Colors.grey,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'New Category',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade300,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) =>
                                      setState(() => _isEditingName = false),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() => _isEditingName = true);
                                  _focusNode.requestFocus();
                                },
                                child: Text(
                                  _nameController.text.isEmpty
                                      ? 'New Category'
                                      : _nameController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        _selectedColor ?? Colors.grey.shade400,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 22),
                  ],
                ),
              ),

              // Palette grid
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 2,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final cellSize =
                        (availableWidth - (cols - 1) * circleSpacing) / cols;
                    final circleSize = cellSize * 0.78;

                    return GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: circleSpacing,
                      crossAxisSpacing: circleSpacing,
                      children: _palette.map((c) {
                        final isSelected = _selectedColor == c;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = c),
                          child: Center(
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 3)
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              // Collaboration + Add
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AppImages.collaboration,
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Collaboration',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                    if (_nameController.text.trim().isNotEmpty &&
                        _selectedColor != null)
                      GestureDetector(
                        onTap: _onAdd,
                        child: Row(
                          children: [
                            Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
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
          child: const Center(
            child: Icon(Icons.add, size: 28, color: Colors.grey),
          ),
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
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
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
