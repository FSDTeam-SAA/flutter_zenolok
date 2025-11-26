import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Adjust if your path is different
import 'package:flutter_zenolok/features/home/presentation/screens/home.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.event});

  final CalendarEvent event;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _labelGrey = Color(0xFFBFC2CB);
  static const _dividerGrey = Color(0xFFE6E7ED);
  static const _lightIconGrey = Color(0xFFD9DCE4);
  static const _todoBubbleBg = Color(0xFFF5F5F7);
  static const _todoHintGrey = Color(0xFFD2D4DC);

  // NEW: controllers for editable fields
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  final TextEditingController _newTodoCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  late List<_TodoItem> _todos;

  CalendarEvent get event => widget.event;

  @override
  void initState() {
    super.initState();

    _titleCtrl = TextEditingController(text: event.title);
    _locationCtrl = TextEditingController(text: event.location ?? '');

    final rawList = event.checklist.isNotEmpty
        ? event.checklist
        : <String>[
      '[ ] Post ig story',
      '[ ] Leaflet giving',
      '[x] Bring staff pass',
    ];

    _todos = rawList.map(_TodoItem.fromRaw).toList();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _newTodoCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      DateFormat('d MMM yyyy').format(d).toUpperCase();
  String _fmtDay(DateTime d) => DateFormat('EEEE').format(d);
  String _fmtTime(DateTime d) => DateFormat('hh : mm').format(d);
  String _fmtAmPm(DateTime d) => DateFormat('a').format(d);

  // NEW: build updated event and pop it
  void _onSave() {
    final updated = CalendarEvent(
      id: event.id,
      category: event.category,
      title: _titleCtrl.text.trim().isEmpty
          ? event.title
          : _titleCtrl.text.trim(),
      start: event.start,
      end: event.end,
      allDay: event.allDay,
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      checklist: _todos
          .map(
            (t) => '${t.checked ? "[x]" : "[ ]"} ${t.label}',
      )
          .toList(),
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;

    final start = event.start;
    final end = event.end ?? event.start;
    final isAllDay = event.allDay;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF8E8E93),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const SizedBox.shrink(),
        // NEW: actions are NOT const and call _onSave
        actions: [
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 22,
              color: Color(0xFFFF4B5C),
            ),
            onPressed: () {
              // if you want delete behaviour later, handle here
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.check_rounded,
              size: 22,
              color: Color(0xFF3AC3FF),
            ),
            onPressed: _onSave,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        children: [
          // ───────── Title + share icon (EDITABLE) ─────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 3,
                height: 22,
                decoration: BoxDecoration(
                  color: event.category.color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.share_outlined,
                size: 18,
                color: _lightIconGrey,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Category pill
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: event.category.color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    event.category.icon,
                    size: 14,
                    color: event.category.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    event.category.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: event.category.color,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Date row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.event_outlined, size: 20, color: _labelGrey),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    // left date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fmtDay(start),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _labelGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmtDate(start),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // right date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _fmtDay(end),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _labelGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmtDate(end),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.notifications_none_rounded,
                size: 18,
                color: _lightIconGrey,
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.autorenew_rounded,
                size: 18,
                color: _lightIconGrey,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Time row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.access_time_rounded, size: 20, color: _labelGrey),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fmtTime(start),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmtAmPm(start),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _labelGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _fmtTime(end),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmtAmPm(end),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _labelGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE7E8EE)),
                ),
                child: Text(
                  'All day',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isAllDay
                        ? const Color(0xFFD0D3DD)
                        : const Color(0xFFD0D3DD),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: _dividerGrey),

          // Location row (EDITABLE)
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.place_outlined, size: 20, color: _labelGrey),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Location',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          // Todo bubble
          _buildTodoBubble(),

          const SizedBox(height: 26),

          // Let's JAM
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock_outline_rounded,
                  size: 16, color: _labelGrey),
              SizedBox(width: 4),
              Text(
                "Let's JAM",
                style: TextStyle(
                  fontSize: 13,
                  color: _labelGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: _labelGrey),
            ],
          ),
        ],
      ),
    );
  }

  // todo bubble
  Widget _buildTodoBubble() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
      decoration: BoxDecoration(
        color: _todoBubbleBg,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _todos.length; i++) ...[
            _TodoRadioRow(
              label: _todos[i].label,
              selected: _todos[i].checked,
              highlightColor: event.category.color,
              onTap: () {
                setState(() {
                  // single selected at a time (like your mock)
                  for (int j = 0; j < _todos.length; j++) {
                    _todos[j] =
                        _todos[j].copyWith(checked: j == i ? true : false);
                  }
                });
              },
            ),
            if (i != _todos.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),

          // New todo
          TextField(
            controller: _newTodoCtrl,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'New todo',
              hintStyle: TextStyle(
                fontSize: 13,
                color: _todoHintGrey,
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              final trimmed = value.trim();
              if (trimmed.isEmpty) return;
              setState(() {
                _todos.add(_TodoItem(label: trimmed, checked: false));
                _newTodoCtrl.clear();
              });
            },
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            color: const Color(0xFFE1E2E8),
          ),
          const SizedBox(height: 6),

          // New notes
          TextField(
            controller: _notesCtrl,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'New notes',
              hintStyle: TextStyle(
                fontSize: 11,
                color: _todoHintGrey,
              ),
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// Radio-like todo row
class _TodoRadioRow extends StatelessWidget {
  const _TodoRadioRow({
    required this.label,
    required this.selected,
    required this.highlightColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color highlightColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
    selected ? highlightColor : const Color(0xFFCDCFD7);
    final fillColor = selected ? highlightColor : Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fillColor,
                ),
              ),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoItem {
  final String label;
  final bool checked;

  const _TodoItem({required this.label, required this.checked});

  factory _TodoItem.fromRaw(String raw) {
    final checked = raw.startsWith('[x]');
    final label = raw.replaceFirst(RegExp(r'^\[( |x)\]\s?'), '');
    return _TodoItem(label: label, checked: checked);
  }

  _TodoItem copyWith({String? label, bool? checked}) {
    return _TodoItem(
      label: label ?? this.label,
      checked: checked ?? this.checked,
    );
  }
}
