import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'package:get/get.dart';

import '../../../todos/data/models/category_model.dart';
import '../../../todos/presentation/controllers/event_totos_controller.dart';
import 'todos_categories_manage_screen.dart';

class CategoryEditDialog extends StatefulWidget {
  final CategoryModel category;

  const CategoryEditDialog({super.key, required this.category});

  @override
  State<CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<CategoryEditDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;
  bool _isEditingName = false;
  final FocusNode _focusNode = FocusNode();

  // Use the same color palette as NewCategoryDialog
  static const List<Color> _colors = TodosCategoriesManageScreen.categoryColors;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedColor = _hexToColor(widget.category.color);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length != 6) return const Color(0xFFBFC1C8);
    return Color(int.parse('FF$h', radix: 16));
  }

  String _colorToHex(Color color) {
    final value = color.value.toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventTodosController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = (screenWidth * 0.85).clamp(260.0, 420.0);
    final maxDialogHeight = screenHeight * 0.85;

    const horizontalPadding = 12.0;
    const circleSpacing = 0.0;
    const cols = 10;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: maxDialogHeight),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(35),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with editable category name (same as NewCategoryDialog)
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
                                    color: _selectedColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Edit Category',
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
                                      ? 'Edit Category'
                                      : _nameController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedColor,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 22),
                  ],
                ),
              ),

              // Color Palette Grid (same as NewCategoryDialog)
              Padding(
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
                      children: _colors.map((c) {
                        final isSelected = _selectedColor.value == c.value;
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

              // Delete Button Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, //  right align
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Category', style: TextStyle(color: Colors.white),),
                            content: Text(
                              'Are you sure you want to delete "${widget.category.name}"? This action cannot be undone.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && mounted) {
                          final success = await controller.deleteCategory(
                            categoryId: widget.category.id,
                          );

                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Category deleted successfully'),
                                backgroundColor: Colors.green,
                                duration: Duration(milliseconds: 1500),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete Category'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Collaboration Section - Icon + Avatars
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Row(
                  children: [
                    // Collaboration Icon - Click to show all users
                    GestureDetector(
                      onTap: () {
                        // TODO: Show all users dialog/bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User selection coming soon'),
                            duration: Duration(milliseconds: 1500),
                          ),
                        );
                      },
                      child: Image.asset(
                        AppImages.collaboration,
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Show avatars of already shared persons
                    Expanded(
                      child: widget.category.participants.isEmpty
                          ? Text(
                              'No collaborators',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            )
                          : SizedBox(
                              height: 32,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.category.participants.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: _selectedColor
                                          .withOpacity(0.2),
                                      child: Text(
                                        widget.category.participants[index]
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // Update Button (same style as NewCategoryDialog)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    Obx(
                      () => GestureDetector(
                        onTap:
                            controller.isCreating.value ||
                                _nameController.text.trim().isEmpty
                            ? null
                            : () async {
                                final success = await controller.updateCategory(
                                  categoryId: widget.category.id,
                                  name: _nameController.text.trim(),
                                  color: _colorToHex(_selectedColor),
                                );

                                if (success && mounted) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Category updated successfully',
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(milliseconds: 1500),
                                      ),
                                    );
                                  }
                                }
                              },
                        child: Row(
                          children: [
                            Text(
                              controller.isCreating.value
                                  ? 'Updating...'
                                  : 'Update',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    controller.isCreating.value ||
                                        _nameController.text.trim().isEmpty
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color:
                                  controller.isCreating.value ||
                                      _nameController.text.trim().isEmpty
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              size: 20,
                            ),
                          ],
                        ),
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
