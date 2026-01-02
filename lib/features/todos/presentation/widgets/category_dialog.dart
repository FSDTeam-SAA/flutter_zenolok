import 'package:flutter/material.dart';
import '../../../../core/common/constants/app_images.dart';

class CategoryDialog extends StatefulWidget {
  final String categoryTitle;
  final Color categoryColor;
  final List<String> initialTodos;

  const CategoryDialog({
    super.key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.initialTodos,
  });

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
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
      // Keep focus on the text field after adding
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
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3B82F6), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                widget.categoryTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: widget.categoryColor,
                ),
              ),
            ),

            // Todo list
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _todos.length,
                  itemBuilder: (context, index) {
                    final todo = _todos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _todos[index]['checked'] =
                                    !_todos[index]['checked'];
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFD0D0D0),
                                  width: 2,
                                ),
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              todo['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Image.asset(
                            AppImages.iconschedule,
                            width: 20,
                            height: 20,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            AppImages.notification2,
                            width: 20,
                            height: 20,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            AppImages.sliders,
                            width: 20,
                            height: 20,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // New todo input section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD0D0D0),
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _newTodoController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'New todo',
                        hintStyle: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFD0D0D0),
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      onSubmitted: (_) => _addNewTodo(),
                    ),
                  ),
                  // Show Done button when typing
                  if (_isTyping) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _addNewTodo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
