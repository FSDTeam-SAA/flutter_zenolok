import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'todo_details_dialog.dart';

class CategoryDetailsDialog extends StatefulWidget {
  final String categoryTitle;
  final Color categoryColor;
  final List<String> initialTodos;

  const CategoryDetailsDialog({
    super.key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.initialTodos,
  });

  @override
  State<CategoryDetailsDialog> createState() => _CategoryDetailsDialogState();
}

class _CategoryDetailsDialogState extends State<CategoryDetailsDialog> {
  late List<Map<String, dynamic>> _todos;
  final TextEditingController _newTodoController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _todos = widget.initialTodos
        .map<Map<String, dynamic>>(
          (title) => <String, dynamic>{'title': title, 'checked': false},
        )
        .toList();

    _newTodoController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _newTodoController.text.isNotEmpty;
    if (_isTyping != hasText) {
      setState(() {
        _isTyping = hasText;
      });
    }
  }

  @override
  void dispose() {
    _newTodoController.removeListener(_onTextChanged);
    _newTodoController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addNewTodo() {
    if (_newTodoController.text.trim().isNotEmpty) {
      final todoText = _newTodoController.text.trim();
      setState(() {
        _todos.add(<String, dynamic>{'title': todoText, 'checked': false});
      });
      _newTodoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.15,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Blurred dark background
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.0)),
              ),
            ),
          ),
          // Header positioned ABOVE the dialog
          Positioned(
            left: 0,
            top: -30,
            child: Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                widget.categoryTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: widget.categoryColor,
                ),
              ),
            ),
          ),
          // Main dialog container
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(35),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Todo list with gray background
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    itemCount: _todos.length + 1,
                    itemBuilder: (context, index) {
                      // Add new todo input at the end
                      if (index == _todos.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Placeholder checkbox
                                },
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 2.5,
                                    ),
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _newTodoController,
                                  focusNode: _focusNode,
                                  decoration: const InputDecoration(
                                    hintText: 'New todo',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFFD0D0D0),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (_isTyping) ...[
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: _addNewTodo,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.categoryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Done',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }

                      // Existing todos
                      final todo = _todos[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Checkbox circle
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _todos[index]['checked'] =
                                      !_todos[index]['checked'];
                                });
                              },
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: widget.categoryColor,
                                    width: 2.5,
                                  ),
                                  color: todo['checked']
                                      ? widget.categoryColor
                                      : Colors.transparent,
                                ),
                                child: todo['checked']
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Todo title
                            Expanded(
                              child: Text(
                                todo['title'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: todo['checked']
                                      ? Colors.grey
                                      : Colors.black87,
                                  decoration: todo['checked']
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            // Icons on the right
                            Image.asset(
                              AppImages.iconschedule,
                              width: 16,
                              height: 16,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 2),
                            Image.asset(
                              AppImages.repeat,
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 2),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => TodoDetailsDialog(
                                    todoTitle: todo['title'],
                                    categoryTitle: widget.categoryTitle,
                                    categoryColor: widget.categoryColor,
                                  ),
                                );
                              },
                              child: Image.asset(
                                AppImages.sliders,
                                width: 16,
                                height: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
