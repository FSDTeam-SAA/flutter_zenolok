import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoBubble extends StatelessWidget {
  const TodoBubble({
    super.key,
    required this.todos,
    required this.newTodoController,
    required this.newNoteController,
    required this.onRemove,
    required this.onSubmitTodo,
    required this.onSubmitNote,
  });

  final List<String> todos;
  final TextEditingController newTodoController;
  final TextEditingController newNoteController;
  final void Function(int index) onRemove;
  final ValueChanged<String> onSubmitTodo;
  final ValueChanged<String> onSubmitNote;

  @override
  Widget build(BuildContext context) {
    const _ = Color(0xFFDBDBDB);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (todos.isNotEmpty) ...[
            for (int i = 0; i < todos.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      todos[i].replaceFirst(RegExp(r'^\[([ x])\]\s?'), ''),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onRemove(i),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFE5E5E5)),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: newTodoController,
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmitTodo,
            maxLines: 1,
            minLines: 1,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'New todo',
              border: InputBorder.none,
              hintStyle: GoogleFonts.nunito(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 16 / 14,
                letterSpacing: 0,
                color: const Color(0xFFD5D5D5),
              ),
            ),
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 16 / 14,
              letterSpacing: 0,
              color: const Color(0xFF4D4D4D),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          const SizedBox(height: 10),
          TextField(
            controller: newNoteController,
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmitNote,
            maxLines: 1,
            minLines: 1,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'New notes',
              border: InputBorder.none,
              hintStyle: GoogleFonts.nunito(
                fontWeight: FontWeight.w400,
                fontSize: 11,
                height: 16 / 11,
                letterSpacing: 0,
                color: const Color(0xFFD5D5D5),
              ),
            ),
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w400,
              fontSize: 11,
              height: 16 / 11,
              letterSpacing: 0,
              color: const Color(0xFF4D4D4D),
            ),
          ),
        ],
      ),
    );
  }
}
