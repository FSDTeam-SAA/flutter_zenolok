import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// your date / time bottom sheets
import '../widgets/date_time_widget.dart';

const Color kScreenBg = Color(0xFFFDFDFD);
const Color kPrimaryBlue = Color(0xFF2E8CFF);
const Color kTodoFill = Color(0xFFF7F7F7);
const Color kTodoBorder = Color(0xFFEFEFEF);
const Color kChatCardFill = Color(0xFFF6F6F6);
const Color kChatInputFill = Color(0xFFEDEDED);
const Color kDividerGrey = Color(0xFFE5E5E5);
const Color kDisabledText = Color(0xFFDBDBDB);

class AllDayScreen extends StatefulWidget {
  const AllDayScreen({Key? key}) : super(key: key);

  @override
  State<AllDayScreen> createState() => _AllDayScreenState();
}

class _AllDayScreenState extends State<AllDayScreen> {
  bool _notifOn = true;
  bool _allDay = true;

  // date + time state
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  // editable location
  late TextEditingController _locationCtrl;

  final List<String> _participants = [
    'Grace Miller',
    'John Doe',
    'Emma',
    'Alex',
  ];

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      senderName: 'Me',
      text: 'I want to make a roast turkey!',
      isMe: true,
      time: DateTime.now().subtract(const Duration(hours: 12)),
      showDayLabel: true,
    ),
    _ChatMessage(
      senderName: 'Grace Miller',
      text: 'That sounds like a great plan!',
      isMe: false,
      time: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _startDate = DateTime(2026, 6, 17);
    _endDate = _startDate;
    _startTime = const TimeOfDay(hour: 12, minute: 0);
    _endTime = const TimeOfDay(hour: 12, minute: 0);

    _locationCtrl = TextEditingController(text: '30, Farm Road');
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  DateTime _combine(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  String _fmtDay(DateTime d) => DateFormat('EEEE').format(d);
  String _fmtDate(DateTime d) =>
      DateFormat('dd MMM yyyy').format(d).toUpperCase();
  String _fmtTime(DateTime d) => DateFormat('hh : mm').format(d);
  String _fmtAmPm(DateTime d) => DateFormat('a').format(d);

  Future<void> _pickDateRange() async {
    final result = await showModalBottomSheet<DateRangeResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateRangeBottomSheet(
        initialStart: _startDate,
        initialEnd: _endDate,
      ),
    );

    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
      });
    }
  }

  Future<void> _pickTimeRange() async {
    final result = await showModalBottomSheet<TimeRangeResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TimeRangeBottomSheet(
        initialStart: _startTime,
        initialEnd: _endTime,
      ),
    );

    if (result != null) {
      setState(() {
        _startTime = result.start;
        _endTime = result.end;
      });
    }
  }

  void _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete event?'),
        content:
        const Text('Are you sure you want to delete this Family Dinner?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted (demo action).')),
      );
    }
  }

  void _showSavedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event saved (demo action).')),
    );
  }

  void _showParticipants() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Participants',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ..._participants.map(
                      (p) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: Text(
                        p.characters.first.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(p),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final startDT = _combine(_startDate, _startTime);
    final endDT = _combine(_endDate, _endTime);

    final String shareDateLabel = _startDate.isAtSameMomentAs(_endDate)
        ? _fmtDate(_startDate)
        : '${_fmtDate(_startDate)} – ${_fmtDate(_endDate)}';

    const double chatPreviewHeight = 250;

    return Scaffold(
      backgroundColor: kScreenBg,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR (delete + check)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Colors.black,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _showDeleteDialog,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: _showSavedSnackBar,
                    icon: const Icon(Icons.check_rounded, color: Colors.green),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE + HOME + AVATARS + SHARE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 3,
                          height: 24,
                          margin: const EdgeInsets.only(top: 3, right: 8),
                          decoration: BoxDecoration(
                            color: kPrimaryBlue,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Family Dinner',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: kPrimaryBlue.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.home_outlined,
                                          size: 14,
                                          color: kPrimaryBlue,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Home',
                                          style: TextStyle(
                                            color: kPrimaryBlue,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _showParticipants,
                          child: SizedBox(
                            width: 72,
                            height: 28,
                            child: Stack(
                              children: List.generate(_participants.length, (i) {
                                return Positioned(
                                  left: i * 16.0,
                                  child: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 11,
                                      backgroundColor: Colors.grey.shade300,
                                      child: Text(
                                        _participants[i]
                                            .characters
                                            .first
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.share_outlined,
                            size: 20,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            final locText = _locationCtrl.text.trim().isEmpty
                                ? 'Location'
                                : _locationCtrl.text.trim();

                            Share.share(
                              'Family Dinner\n$shareDateLabel – '
                                  '${_allDay ? "All day" : "Timed"}\n$locText',
                              subject: 'Family Dinner',
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // DATE ROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _pickDateRange,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fmtDay(_startDate),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey.shade500,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _startDate.isAtSameMomentAs(_endDate)
                                      ? _fmtDate(_startDate)
                                      : '${_fmtDate(_startDate)}   –   ${_fmtDate(_endDate)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          splashRadius: 20,
                          onPressed: () {
                            setState(() => _notifOn = !_notifOn);
                          },
                          icon: Icon(
                            _notifOn
                                ? Icons.notifications_none_rounded
                                : Icons.notifications_off_outlined,
                            size: 20,
                            color: _notifOn
                                ? Colors.grey.shade700
                                : Colors.grey.shade400,
                          ),
                        ),
                        IconButton(
                          splashRadius: 20,
                          onPressed: () {},
                          icon: Icon(
                            Icons.autorenew_rounded,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // TIME ROW (only when not All day)
                    if (!_allDay) ...[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _pickTimeRange,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 32.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _fmtTime(startDT),
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _fmtAmPm(startDT),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: Colors.grey.shade500,
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
                                      _fmtTime(endDT),
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _fmtAmPm(endDT),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ALL DAY ROW
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'All day',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() => _allDay = !_allDay);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _allDay
                                    ? Colors.black87
                                    : Colors.grey.shade500,
                                width: 1.1,
                              ),
                            ),
                            child: Text(
                              'All day',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: _allDay
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // LOCATION ROW (editable)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _locationCtrl,
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText: '30, Farm Road',
                                ),
                                style:
                                theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Location',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // TODO CARDS
                    const TodoInputCard(
                      initialTitle: 'New todo',
                      initialNotes: '',
                    ),
                    const SizedBox(height: 12),
                    const TodoInputCard(
                      initialTitle: 'New shared todo',
                      initialNotes: '',
                    ),

                    const SizedBox(height: 24),

                    // CHAT PREVIEW CARD -> FULL SCREEN CHAT
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ChatExpandedScreen(messages: _messages),
                          ),
                        );
                        setState(() {});
                      },
                      child: Container(
                        height: chatPreviewHeight,
                        decoration: BoxDecoration(
                          color: kChatCardFill,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Icon(
                                Icons.image_outlined,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                itemCount:
                                _messages.length.clamp(0, 2),
                                separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final msgIndex = _messages.length > 2
                                      ? _messages.length - 2 + index
                                      : index;
                                  final msg = _messages[msgIndex];
                                  return _ChatRow(message: msg);
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: kChatInputFill,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 20,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Type here...',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: const BoxDecoration(
                                      color: kPrimaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.send_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
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

            // BOTTOM "Let's JAM"
            Container(
              padding: const EdgeInsets.only(bottom: 14, top: 6),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Let's JAM",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- TodoInputCard -------------------- */

class TodoInputCard extends StatefulWidget {
  final String initialTitle;
  final String initialNotes;

  const TodoInputCard({
    Key? key,
    this.initialTitle = 'New todo',
    this.initialNotes = '',
  }) : super(key: key);

  @override
  State<TodoInputCard> createState() => _TodoInputCardState();
}

class _TodoInputCardState extends State<TodoInputCard> {
  late TextEditingController _titleCtrl;
  late TextEditingController _notesCtrl;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: '');
    _notesCtrl = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _titleFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_titleCtrl.text.isEmpty) {
          _titleFocus.requestFocus();
        } else {
          _notesFocus.requestFocus();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: kTodoFill,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: kTodoBorder),
        ),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              focusNode: _titleFocus,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.initialTitle,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kDisabledText,
                ),
              ),
              onSubmitted: (_) => _notesFocus.requestFocus(),
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 6),
              color: kDividerGrey,
            ),
            TextField(
              controller: _notesCtrl,
              focusNode: _notesFocus,
              maxLines: 2,
              minLines: 1,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'New notes',
                hintStyle: TextStyle(fontSize: 12, color: kDisabledText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- Chat models / rows -------------------- */

class _ChatMessage {
  final String senderName;
  final String text;
  final bool isMe;
  final DateTime time;
  final bool showDayLabel;

  _ChatMessage({
    required this.senderName,
    required this.text,
    required this.isMe,
    required this.time,
    this.showDayLabel = false,
  });
}

class _ChatRow extends StatelessWidget {
  final _ChatMessage message;

  const _ChatRow({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat('hh:mm a').format(message.time);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 14, backgroundColor: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.senderName,
                style: const TextStyle(
                  color: kPrimaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  message.text,
                  style: const TextStyle(fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.showDayLabel)
              Text(
                'yesterday',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            if (message.showDayLabel) const SizedBox(height: 2),
            Text(
              timeLabel,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }
}

/* -------------------- Full-screen chat -------------------- */

class ChatExpandedScreen extends StatefulWidget {
  final List<_ChatMessage> messages;

  const ChatExpandedScreen({Key? key, required this.messages})
      : super(key: key);

  @override
  State<ChatExpandedScreen> createState() => _ChatExpandedScreenState();
}

class _ChatExpandedScreenState extends State<ChatExpandedScreen> {
  final TextEditingController _controller = TextEditingController();

  List<_ChatMessage> get _messages => widget.messages;

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(
          senderName: 'Me',
          text: text,
          isMe: true,
          time: DateTime.now(),
        ),
      );
    });
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Colors.grey,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Media, files, link',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ListView.builder(
                    reverse: false,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final timeLabel =
                      DateFormat('hh:mm a').format(msg.time);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.senderName,
                                    style: const TextStyle(
                                      color: kPrimaryBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: const TextStyle(fontSize: 13.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (msg.showDayLabel)
                                  Text(
                                    'Yesterday',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                if (msg.showDayLabel)
                                  const SizedBox(height: 2),
                                Text(
                                  timeLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.image_outlined),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type here...',
                        ),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kPrimaryBlue,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
