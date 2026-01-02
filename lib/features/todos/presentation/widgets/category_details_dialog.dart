import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';

import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'package:get/get.dart';
import '../controllers/event_totos_controller.dart';
import 'todo_details_dialog.dart';

class CategoryDetailsDialog extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final Color categoryColor;
  final List<String> initialTodos;
  final VoidCallback? onTodoAdded;

  const CategoryDetailsDialog({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryColor,
    required this.initialTodos,
    this.onTodoAdded,
  });

  @override
  State<CategoryDetailsDialog> createState() => _CategoryDetailsDialogState();
}

class _CategoryDetailsDialogState extends State<CategoryDetailsDialog> {
  late List<Map<String, dynamic>> _todos;
  final TextEditingController _newTodoController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _todos = [];
    if (kDebugMode) {
      print('╔════════════════════════════════════════════════════════════════╗');
      print('║ CategoryDetailsDialog INIT STATE                               ║');
      print('║ Category ID: ${widget.categoryId}                              ║');
      print('║ Category Title: ${widget.categoryTitle}                          ║');
      print('╚════════════════════════════════════════════════════════════════╝');
    }
    _newTodoController.addListener(_onTextChanged);
    _fetchTodos();
  }

  void _fetchTodos() async {
    if (kDebugMode) {
      print('📱 Dialog: Fetching todos for category: ${widget.categoryId}');
    }

    final controller = Get.find<EventTodosController>();
    final todos = await controller.fetchTodoItemsByCategory(
      categoryId: widget.categoryId,
    );
    
    if (kDebugMode) {
      print('📱 Dialog: Received ${todos.length} todos');
      for (int i = 0; i < todos.length; i++) {
        print('   ${i + 1}. ${todos[i]['title']}');
      }
    }

    setState(() {
      _todos = todos;
      _isLoading = false;
    });

    if (kDebugMode) {
      print('📱 Dialog: setState done, _todos.length = ${_todos.length}');
    }
  }

  void _onTextChanged() {
    final hasText = _newTodoController.text.isNotEmpty;
    if (_isTyping != hasText) {
      if (mounted) {
        setState(() {
          _isTyping = hasText;
        });
      }
    }
  }

  @override
  void dispose() {
    _newTodoController.removeListener(_onTextChanged);
    _newTodoController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addNewTodo() async {
    if (_newTodoController.text.trim().isEmpty) {
      return;
    }

    final todoText = _newTodoController.text.trim();
    
    if (kDebugMode) {
      print('➕ Dialog: Adding new todo: $todoText');
    }

    // Immediately clear the form
    setState(() {
      _newTodoController.clear();
      _isTyping = false;
    });

    // Call the API to create todo item
    final controller = Get.find<EventTodosController>();
    final success = await controller.createTodoItem(
      categoryId: widget.categoryId,
      text: todoText,
    );

    if (success) {
      if (kDebugMode) {
        print('✅ Dialog: Todo added successfully');
      }

      // Refresh the todo list from API to get the latest data
      if (mounted) {
        _fetchTodos();
      }

      // Trigger instant grid update
      if (widget.onTodoAdded != null) {
        if (kDebugMode) {
          print('🔄 Dialog: Refreshing category card...');
        }
        widget.onTodoAdded!();
      }

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Todo "$todoText" added successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      if (kDebugMode) {
        print('❌ Dialog: Failed to add todo');
      }

      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Failed to add todo: ${controller.errorMessage.value}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
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
                // Loading state or Todo list
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 20,
                    ),
                    child: CircularProgressIndicator(),
                  )
                else
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
