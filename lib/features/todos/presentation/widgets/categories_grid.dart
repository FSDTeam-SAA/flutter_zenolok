import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'package:get/get.dart';
import '../controllers/event_totos_controller.dart';
import 'category_details_dialog.dart';

class CategoriesGrid extends GetView<EventTodosController> {
  CategoriesGrid({super.key});

  final Map<String, GlobalKey<_CategoryCardState>> _cardKeys = {};

  void _openCategory(BuildContext context, int index) {
    final category = controller.categories[index];
    if (kDebugMode) {
      print('🎯 Grid: Opening category');
      print('   Name: ${category.name}');
      print('   ID: ${category.id}');
      print('   Color: ${category.color}');
    }
    showDialog(
      context: context,
      builder: (context) => CategoryDetailsDialog(
        categoryId: category.id,
        categoryTitle: category.name,
        categoryColor: _hexToColor(category.color),
        initialTodos: [],
        onTodoAdded: () {
          // Refresh the category card when a todo is added
          final key = _cardKeys[category.id];
          if (key?.currentState != null && key!.currentState!.mounted) {
            if (kDebugMode) {
              print('🎯 Grid: Refreshing category card ${category.id} instantly');
            }
            key.currentState!.refreshTodos();
          }
        },
      ),
    ).then((_) {
      // Refresh the specific category card when dialog closes
      if (kDebugMode) {
        print('🎯 Grid: Dialog closed, refreshing category card ${category.id}');
      }
      // Refresh the category card for the one we just added todos to
      final key = _cardKeys[category.id];
      if (key?.currentState != null && key!.currentState!.mounted) {
        key.currentState!.refreshTodos();
      }
    });
  }

  Future<void> _openNewCategoryDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const NewCategoryDialog(),
    );

    if (result != null && result['title'] != null && result['color'] != null) {
      if (context.mounted) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Call controller to create category
        final success = await controller.createCategory(
          name: result['title'] as String,
          color: result['color'] as String,
        );

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Category "${result['title']}" created successfully! ✅'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create category: ${controller.errorMessage.value}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse('0x$hexColor'));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (kDebugMode) {
        print('🔍 CategoriesGrid rebuild triggered');
        print('   isLoading: ${controller.isLoading.value}');
        print('   categories count: ${controller.categories.length}');
        print('   errorMessage: ${controller.errorMessage.value}');
      }

      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${controller.errorMessage.value}'),
            ],
          ),
        );
      }

      final categories = controller.categories;
      
      if (kDebugMode) {
        print('📊 Building grid with ${categories.length} categories');
        for (int i = 0; i < categories.length; i++) {
          print('   $i: ${categories[i].name} (${categories[i].color})');
        }
      }

      // If no categories, show only add button
      if (categories.isEmpty) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _AddCategoryCard(
                    onTap: () => _openNewCategoryDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        );
      }

      // Build rows of two cards each, final slot is add button
      final List<Widget> rows = [];
      final totalSlots = categories.length + 1; // +1 for add card

      for (int i = 0; i < totalSlots; i += 2) {
        final leftIndex = i;
        final rightIndex = i + 1;

        Widget leftChild;
        if (leftIndex < categories.length) {
          final c = categories[leftIndex];
          // Create or reuse GlobalKey for this category
          if (!_cardKeys.containsKey(c.id)) {
            _cardKeys[c.id] = GlobalKey<_CategoryCardState>();
          }
          leftChild = _CategoryCard(
            key: _cardKeys[c.id],
            categoryId: c.id,
            title: c.name,
            titleColor: _hexToColor(c.color),
            onTap: () => _openCategory(context, leftIndex),
          );
        } else {
          leftChild = _AddCategoryCard(
            onTap: () => _openNewCategoryDialog(context),
          );
        }

        Widget rightChild;
        if (rightIndex < categories.length) {
          final c = categories[rightIndex];
          // Create or reuse GlobalKey for this category
          if (!_cardKeys.containsKey(c.id)) {
            _cardKeys[c.id] = GlobalKey<_CategoryCardState>();
          }
          rightChild = _CategoryCard(
            key: _cardKeys[c.id],
            categoryId: c.id,
            title: c.name,
            titleColor: _hexToColor(c.color),
            onTap: () => _openCategory(context, rightIndex),
          );
        } else if (rightIndex == categories.length) {
          rightChild = _AddCategoryCard(
            onTap: () => _openNewCategoryDialog(context),
          );
        } else {
          rightChild = const SizedBox.shrink();
        }

        rows.add(
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openCategory(context, leftIndex),
                  child: leftChild,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: rightIndex < categories.length
                      ? () => _openCategory(context, rightIndex)
                      : null,
                  child: rightChild,
                ),
              ),
            ],
          ),
        );

        rows.add(const SizedBox(height: 12));
      }

      // Remove the trailing SizedBox
      if (rows.isNotEmpty) rows.removeLast();

      if (kDebugMode) {
        print('✅ Grid built with ${rows.length} rows');
      }

      return Column(children: rows);
    });
  }
}

class _CategoryCard extends StatefulWidget {
  final String categoryId;
  final String title;
  final Color titleColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required super.key,
    required this.categoryId,
    required this.title,
    required this.titleColor,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  List<String> _todos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  // Public method to refresh todos
  void refreshTodos() {
    if (mounted) {
      _fetchTodos();
    }
  }

  Future<void> _fetchTodos() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final controller = Get.find<EventTodosController>();
      final todos = await controller.fetchTodoItemsByCategory(
        categoryId: widget.categoryId,
      );

      if (kDebugMode) {
        print('🎨 CategoryCard: Fetched ${todos.length} todos for ${widget.title}');
      }

      if (mounted) {
        setState(() {
          // Show only first 3 todos in preview
          _todos = todos
              .take(3)
              .map((todo) => todo['title'] as String)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CategoryCard: Error fetching todos - $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Title outside the card (top) with padding
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.titleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          /// Actual card
          Container(
            height: 140,
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
                  if (_isLoading)
                    const SizedBox(
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  else if (_todos.isNotEmpty)
                    ..._todos.map(
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
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Empty state - same layout as with items
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const _TodoCircle(),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No todos yet',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFD0D0D0),
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
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
      ),
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
    
    // Convert Color to hex string
    final hexColor = '#${_selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}';
    
    Navigator.of(context).pop({
      'title': _nameController.text.trim(),
      'color': hexColor,
    });
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
