import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../todos/data/models/category_model.dart';
import '../../../todos/presentation/controllers/event_totos_controller.dart';
import '../../../todos/presentation/widgets/categories_grid.dart';
import 'category_edit_dialog.dart';

class TodosCategoriesManageScreen extends GetView<EventTodosController> {
  const TodosCategoriesManageScreen({super.key});

  static const List<Color> categoryColors = [
    // Row 1 - Bright colors
    Color(0xFFFF383C),
    Color(0xFFFF8D28),
    Color(0xFFFFCC00),
    Color(0xFF34C759),
    Color(0xFF00C0E8),
    Color(0xFF0088FF),
    Color(0xFF6155F5),
    Color(0xFFCB30E0),
    Color(0xFFFF2D55),
    Color(0xFFAC7F5E),
    // Row 2 - Light/Pastel colors
    Color(0xFFFFC2BD),
    Color(0xFFFFD4AE),
    Color(0xFFFFF4C6),
    Color(0xFFE4F3E8),
    Color(0xFFCAEBF2),
    Color(0xFFE0EBF3),
    Color(0xFFEAE9F4),
    Color(0xFFF4E5F6),
    Color(0xFFFFE8EC),
    Color(0xFFEEE4DC),
    // Row 3 - Medium/Muted colors
    Color(0xFFC36062),
    Color(0xFFE6D6C8),
    Color(0xFFDFD5AD),
    Color(0xFFCCDED0),
    Color(0xFFABC3C8),
    Color(0xFFB3C1CD),
    Color(0xFFB3C1CD),
    Color(0xFFB8B6CA),
    Color(0xFFC8939D),
    Color(0xFFA69588),
    // Row 4 - Dark colors
    Color(0xFF9C2426),
    Color(0xFFBD7434),
    Color(0xFF72611E),
    Color(0xFF3F694A),
    Color(0xFF1E6372),
    Color(0xFF26537A),
    Color(0xFF514E73),
    Color(0xFF674B6B),
    Color(0xFF732D3A),
    Color(0xFF5B4230),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Todos Categories',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshCategories();
          },
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Error: ${controller.errorMessage.value}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => controller.fetchCategories(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No categories found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                mainAxisExtent: 48,
              ),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return _buildCategoryCard(context, category);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryModel category) {
    final categoryColor = _hexToColor(category.color);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CategoryEditDialog(category: category),
        );
      },
      onLongPress: () => _showDeleteConfirmation(context, category),
      child: Container(
        decoration: BoxDecoration(
          color: categoryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
       child: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // Category Name
    Expanded(
      child: Text(
        category.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),

    const SizedBox(width: 8),

    // Edit Icon
    const Icon(
      Icons.edit_outlined,
      color: Colors.white,
      size: 18,
    ),
  ],
),

      ),
    );
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length != 6) return const Color(0xFFBFC1C8);
    return Color(int.parse('FF$h', radix: 16));
  }

  void _showDeleteConfirmation(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delete Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to delete "${category.name}"?',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement delete API call
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Delete "${category.name}" functionality coming soon',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
