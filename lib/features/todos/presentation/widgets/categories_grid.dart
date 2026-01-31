import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'package:get/get.dart';
import '../controllers/event_totos_controller.dart';
import 'category_details_dialog.dart';
import '../../../home/presentation/screens/category_edit_dialog.dart';

class CategoriesGrid extends StatefulWidget {
  const CategoriesGrid({super.key});

  @override
  State<CategoriesGrid> createState() => _CategoriesGridState();
}

class _CategoriesGridState extends State<CategoriesGrid> with TickerProviderStateMixin {
  final Map<String, GlobalKey<_CategoryCardState>> _cardKeys = {};
  final _draggingCategoryId = Rxn<String>();
  final _hoverIndex = Rxn<int>();
  AnimationController? _shakeController;

  EventTodosController get controller => Get.find<EventTodosController>();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shakeController?.dispose();
    super.dispose();
  }

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
              print(
                '🎯 Grid: Refreshing category card ${category.id} instantly',
              );
            }
            key.currentState!.refreshTodos();
          }
        },
      ),
    ).then((_) {
      // Refresh the specific category card when dialog closes
      if (kDebugMode) {
        print(
          '🎯 Grid: Dialog closed, refreshing category card ${category.id}',
        );
      }
      // Refresh the category card for the one we just added todos to
      final key = _cardKeys[category.id];
      if (key?.currentState != null && key!.currentState!.mounted) {
        key.currentState!.refreshTodos();
      }
    });
  }

  void _openEditCategory(BuildContext context, int index) {
    final category = controller.categories[index];
    if (kDebugMode) {
      print('✏️ Grid: Opening category edit');
      print('   Name: ${category.name}');
      print('   ID: ${category.id}');
      print('   Color: ${category.color}');
    }

    showDialog(
      context: context,
      builder: (context) => CategoryEditDialog(
        category: category,
      ),
    ).then((_) {
      // Refresh categories after edit
      if (kDebugMode) {
        print('✏️ Grid: Edit dialog closed, refreshing categories');
      }
      controller.refreshCategories();
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
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Call controller to create category
        final success = await controller.createCategory(
          name: result['title'] as String,
          color: result['color'] as String,
        );

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog

          if (success) {
            if (kDebugMode) {
              print(' Category created, forcing grid refresh');
              print('   Total categories now: ${controller.categories.length}');
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Category "${result['title']}" created successfully! ',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(milliseconds: 1500),
              ),
            );

            // Force refresh of the observable list to ensure grid rebuilds
            // This explicitly notifies all listeners about the change
            controller.categories.refresh();

            // Clear GlobalKeys to ensure new cards are properly initialized
            _cardKeys.clear();

            if (kDebugMode) {
              print('🔄 Grid refresh triggered, card keys cleared');
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to create category: ${controller.errorMessage.value}',
                ),
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

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    
    final categories = controller.categories;
    // Swap the two categories directly
    final temp = categories[oldIndex];
    categories[oldIndex] = categories[newIndex];
    categories[newIndex] = temp;
    controller.categories.refresh();
    
    // Clear hover state after reorder
    _hoverIndex.value = null;

    if (kDebugMode) {
      print('🔄 Swapped categories at index $oldIndex and $newIndex');
      print('   New order: ${controller.categories.map((c) => c.name).join(", ")}');
    }

    // TODO: Optionally save order to backend
    // controller.updateCategoryOrder(controller.categories.map((c) => c.id).toList());
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
        return const Center(child: CircularProgressIndicator());
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
          
          final categoryCard = _CategoryCard(
            key: _cardKeys[c.id],
            categoryId: c.id,
            title: c.name,
            titleColor: _hexToColor(c.color),
            onTap: () => _openCategory(context, leftIndex),
            onTitleTap: () => _openEditCategory(context, leftIndex),
          );

          // Wrap with drag target and draggable
          leftChild = DragTarget<int>(
            onAcceptWithDetails: (details) {
              _onReorder(details.data, leftIndex);
            },
            onWillAcceptWithDetails: (details) {
              if (details.data != leftIndex) {
                _hoverIndex.value = leftIndex;
              }
              return details.data != leftIndex;
            },
            onLeave: (_) {
              _hoverIndex.value = null;
            },
            builder: (context, candidateData, rejectedData) {
              return LongPressDraggable<int>(
                data: leftIndex,
                onDragStarted: () {
                  _draggingCategoryId.value = c.id;
                },
                onDragEnd: (_) {
                  _draggingCategoryId.value = null;
                  _hoverIndex.value = null;
                },
                feedback: Material(
                  color: Colors.transparent,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(35),
                  child: Transform.scale(
                    scale: 1.1,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.42,
                      child: _DraggingCategoryFeedback(
                        categoryName: c.name,
                        categoryColor: _hexToColor(c.color),
                        cardKey: _cardKeys[c.id],
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.2,
                  child: Transform.scale(
                    scale: 0.95,
                    child: categoryCard,
                  ),
                ),
                child: Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: _hoverIndex.value == leftIndex
                          ? Border.all(
                              color: _hexToColor(c.color).withOpacity(0.6),
                              width: 3,
                            )
                          : null,
                    ),
                    child: _draggingCategoryId.value != null
                      ? AnimatedBuilder(
                          animation: _shakeController!,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _shakeController!.value * 0.05 - 0.025,
                              child: Transform.translate(
                                offset: Offset(
                                  _shakeController!.value * 4 - 2,
                                  0,
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: categoryCard,
                        )
                      : categoryCard,
                  ),
                ),
              );
            },
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
          
          final categoryCard = _CategoryCard(
            key: _cardKeys[c.id],
            categoryId: c.id,
            title: c.name,
            titleColor: _hexToColor(c.color),
            onTap: () => _openCategory(context, rightIndex),
            onTitleTap: () => _openEditCategory(context, rightIndex),
          );

          // Wrap with drag target and draggable
          rightChild = DragTarget<int>(
            onAcceptWithDetails: (details) {
              _onReorder(details.data, rightIndex);
            },
            onWillAcceptWithDetails: (details) {
              if (details.data != rightIndex) {
                _hoverIndex.value = rightIndex;
              }
              return details.data != rightIndex;
            },
            onLeave: (_) {
              _hoverIndex.value = null;
            },
            builder: (context, candidateData, rejectedData) {
              return LongPressDraggable<int>(
                data: rightIndex,
                onDragStarted: () {
                  _draggingCategoryId.value = c.id;
                },
                onDragEnd: (_) {
                  _draggingCategoryId.value = null;
                  _hoverIndex.value = null;
                },
                feedback: Material(
                  color: Colors.transparent,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(35),
                  child: Transform.scale(
                    scale: 1.1,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.42,
                      child: _DraggingCategoryFeedback(
                        categoryName: c.name,
                        categoryColor: _hexToColor(c.color),
                        cardKey: _cardKeys[c.id],
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.2,
                  child: Transform.scale(
                    scale: 0.95,
                    child: categoryCard,
                  ),
                ),
                child: Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: _hoverIndex.value == rightIndex
                          ? Border.all(
                              color: _hexToColor(c.color).withOpacity(0.6),
                              width: 3,
                            )
                          : null,
                    ),
                    child: _draggingCategoryId.value != null
                        ? AnimatedBuilder(
                          animation: _shakeController!,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _shakeController!.value * 0.05 - 0.025,
                              child: Transform.translate(
                                offset: Offset(
                                  _shakeController!.value * 4 - 2,
                                  0,
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: categoryCard,
                        )
                      : categoryCard,
                  ),
                ),
              );
            },
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
  final VoidCallback? onTitleTap;

  const _CategoryCard({
    required super.key,
    required this.categoryId,
    required this.title,
    required this.titleColor,
    required this.onTap,
    this.onTitleTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  final _todos = <String>[].obs;
  final _totalTodosCount = 0.obs;
  final _isLoading = false.obs;

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

  // Public method to get current todos for drag feedback
  List<String> get currentTodos => _todos.toList();
  int get totalCount => _totalTodosCount.value;
  bool get isLoading => _isLoading.value;

  Future<void> _fetchTodos() async {
    _isLoading.value = true;

    try {
      final controller = Get.find<EventTodosController>();
      final todos = await controller.fetchTodoItemsByCategory(
        categoryId: widget.categoryId,
      );

      if (kDebugMode) {
        print(
          '🎨 CategoryCard: Fetched ${todos.length} todos for ${widget.title}',
        );
      }

      // Store total count and show only first 3 todos in preview
      _totalTodosCount.value = todos.length;
      _todos.value = todos
          .take(3)
          .map((todo) => todo['title'] as String)
          .toList();
      _isLoading.value = false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CategoryCard: Error fetching todos - $e');
      }
      _isLoading.value = false;
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
          /// Title with counter badge outside (top row)
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.onTitleTap,
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
                  if (_totalTodosCount.value > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: widget.titleColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _totalTodosCount.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// Actual card
          Obx(
            () => Container(
              height: 140,
              width: double.infinity,
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
                    if (_isLoading.value)
                      const SizedBox(
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
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
                  //   Padding(
                  //     padding: const EdgeInsets.only(bottom: 8.0),
                  //     child: Row(
                  //       children: [
                  //         const _TodoCircle(),
                  //         const SizedBox(width: 8),
                  //         Expanded(
                  //           child: Text(
                  //             'No todos yet',
                  //             style: const TextStyle(
                  //               fontSize: 13,
                  //               color: Color(0xFFD0D0D0),
                  //               fontWeight: FontWeight.w400,
                  //             ),
                  //             overflow: TextOverflow.ellipsis,
                  //             maxLines: 1,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // const SizedBox(height: 4),
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
  final _selectedColor = Rxn<Color>();
  final _isEditingName = true.obs;
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
    if (_nameController.text.trim().isEmpty || _selectedColor.value == null) return;

    // Convert Color to hex string
    final hexColor =
        '#${_selectedColor.value!.value.toRadixString(16).substring(2).toUpperCase()}';

    Navigator.of(
      context,
    ).pop({'title': _nameController.text.trim(), 'color': hexColor});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = (screenWidth * 0.85).clamp(260.0, 420.0);
    final maxDialogHeight = screenHeight * 0.85; // Maximum height (allow more space)

    const horizontalPadding = 12.0;
    const circleSpacing = 0.0;
    const cols = 10;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 40,
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(35),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Obx(
                () => Padding(
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
                          child: _isEditingName.value
                              ? SizedBox(
                                  width: dialogWidth * 0.6,
                                  child: TextField(
                                    controller: _nameController,
                                    focusNode: _focusNode,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedColor.value ?? Colors.grey,
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
                                    onSubmitted: (_) => _isEditingName.value = false,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    _isEditingName.value = true;
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
                                          _selectedColor.value ?? Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 22),
                    ],
                  ),
                ),
              ),

              // Palette grid
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 8,
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
                          final isSelected = _selectedColor.value == c;
                          return GestureDetector(
                            onTap: () => _selectedColor.value = c,
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
              ),

              // Collaboration + Add
              Obx(
                () => Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
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
                          _selectedColor.value != null)
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Optional: just normal border with dashed effect
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

class _DraggingCategoryFeedback extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;
  final GlobalKey<_CategoryCardState>? cardKey;

  const _DraggingCategoryFeedback({
    required this.categoryName,
    required this.categoryColor,
    this.cardKey,
  });

  @override
  Widget build(BuildContext context) {
    // Get todos from the card state if available
    final cardState = cardKey?.currentState;
    final todos = cardState?.currentTodos ?? [];
    final totalCount = cardState?.totalCount ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 3,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with counter badge
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8, top: 8, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: categoryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (totalCount > 0)
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        totalCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Card content with todos
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(35),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (todos.isNotEmpty)
                  ...todos.take(3).map(
                    (todo) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFD0D0D0),
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              todo,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD0D0D0),
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'No todos yet',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFD0D0D0),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
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
        ],
      ),
    );
  }
}

