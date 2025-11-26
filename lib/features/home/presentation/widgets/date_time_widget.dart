import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// ---------------------------------------------------------------------------
/// HELPER RESULTS
/// ---------------------------------------------------------------------------

class TimeRangeResult {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRangeResult({required this.start, required this.end});
}

class DateRangeResult {
  /// All selected days (normalized to yyyy-mm-dd and sorted).
  final List<DateTime> days;

  DateRangeResult({required List<DateTime> days})
      : days = days.map(_dOnly).toList()..sort((a, b) => a.compareTo(b));

  /// Convenience for existing code – first & last selected day.
  DateTime get start => days.first;

  DateTime get end => days.last;
}

/// ---------------------------------------------------------------------------
/// TIME RANGE BOTTOM SHEET  (custom keypad, centered, no overflow)
/// ---------------------------------------------------------------------------

class TimeRangeBottomSheet extends StatefulWidget {
  const TimeRangeBottomSheet({
    super.key,
    required this.initialStart,
    required this.initialEnd,
  });

  final TimeOfDay initialStart;
  final TimeOfDay initialEnd;

  @override
  State<TimeRangeBottomSheet> createState() => _TimeRangeBottomSheetState();
}

class _TimeRangeBottomSheetState extends State<TimeRangeBottomSheet> {
  static const _accent = Color(0xFFFF6B6B);

  bool _editingStart = true;
  late String _startDigits;
  late String _endDigits;
  late bool _startIsPm;
  late bool _endIsPm;

  @override
  void initState() {
    super.initState();
    _startDigits = '';
    _endDigits = '';
    _startIsPm = widget.initialStart.period == DayPeriod.pm;
    _endIsPm = widget.initialEnd.period == DayPeriod.pm;
  }

  TimeOfDay _digitsToTime(String digits, bool isPm, TimeOfDay fallback) {
    if (digits.isEmpty) return fallback;

    if (digits.length < 4) digits = digits.padRight(4, '0');
    int h = int.tryParse(digits.substring(0, 2)) ?? 0;
    int m = int.tryParse(digits.substring(2, 4)) ?? 0;

    h = h.clamp(1, 12);
    m = m.clamp(0, 59);

    int hour24;
    if (isPm) {
      hour24 = (h % 12) + 12;
    } else {
      hour24 = h % 12;
    }

    return TimeOfDay(hour: hour24, minute: m);
  }

  void _onDigitTap(int digit) {
    setState(() {
      if (_editingStart) {
        if (_startDigits.length < 4) {
          _startDigits += digit.toString();
        }
      } else {
        if (_endDigits.length < 4) {
          _endDigits += digit.toString();
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_editingStart) {
        if (_startDigits.isNotEmpty) {
          _startDigits =
              _startDigits.substring(0, _startDigits.length - 1);
        }
      } else {
        if (_endDigits.isNotEmpty) {
          _endDigits = _endDigits.substring(0, _endDigits.length - 1);
        }
      }
    });
  }

  void _onClear() {
    setState(() {
      if (_editingStart) {
        _startDigits = '';
      } else {
        _endDigits = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = min(constraints.maxWidth - 32, 360.0);

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Set time',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F6F6),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Start Time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _editingStart
                                            ? _accent
                                            : const Color(0xFFB8BBC5),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'End Time',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: !_editingStart
                                            ? _accent
                                            : const Color(0xFFB8BBC5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(
                                              () => _editingStart = true),
                                      child: _TimeDigitDisplay(
                                        digits: _startDigits,
                                        isActive: _editingStart,
                                        accent: _accent,
                                        alignRight: false,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '—',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFFB8BBC5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(
                                              () => _editingStart = false),
                                      child: _TimeDigitDisplay(
                                        digits: _endDigits,
                                        isActive: !_editingStart,
                                        accent: _accent,
                                        alignRight: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _AmPmRow(
                                      isPm: _startIsPm,
                                      accent: _accent,
                                      onChanged: (isPm) => setState(() {
                                        _startIsPm = isPm;
                                      }),
                                      alignRight: false,
                                    ),
                                  ),
                                  Expanded(
                                    child: _AmPmRow(
                                      isPm: _endIsPm,
                                      accent: _accent,
                                      onChanged: (isPm) => setState(() {
                                        _endIsPm = isPm;
                                      }),
                                      alignRight: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _NumberPad(
                                onDigit: _onDigitTap,
                                onBackspace: _onBackspace,
                                onClear: _onClear,
                                accent: _accent,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              final start = _digitsToTime(
                                _startDigits,
                                _startIsPm,
                                widget.initialStart,
                              );
                              final end = _digitsToTime(
                                _endDigits,
                                _endIsPm,
                                widget.initialEnd,
                              );
                              Navigator.pop(
                                context,
                                TimeRangeResult(start: start, end: end),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                            ),
                            child: const Text(
                              'Apply time',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _accent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeDigitDisplay extends StatelessWidget {
  const _TimeDigitDisplay({
    required this.digits,
    required this.isActive,
    required this.accent,
    this.alignRight = false,
  });

  final String digits;
  final bool isActive;
  final Color accent;
  final bool alignRight;

  String _digitOrZero(int index) {
    if (index < 0 || index >= digits.length) return '0';
    return digits[index];
  }

  Widget _bubble(String text, bool filled) {
    final bool highlight = isActive && filled;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlight
            ? accent.withOpacity(0.18)
            : const Color(0xFFE5E5E5),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: highlight ? accent : const Color(0xFFB8BBC5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d1 = _digitOrZero(0);
    final d2 = _digitOrZero(1);
    final d3 = _digitOrZero(2);
    final d4 = _digitOrZero(3);

    final innerRow = Row(
      mainAxisAlignment:
      alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        _bubble(d1, digits.length >= 1),
        const SizedBox(width: 4),
        _bubble(d2, digits.length >= 2),
        const SizedBox(width: 4),
        const Text(
          ':',
          style: TextStyle(fontSize: 16, color: Color(0xFFB8BBC5)),
        ),
        const SizedBox(width: 4),
        _bubble(d3, digits.length >= 3),
        const SizedBox(width: 4),
        _bubble(d4, digits.length >= 4),
      ],
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignRight
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: innerRow,
    );
  }
}

class _AmPmRow extends StatelessWidget {
  const _AmPmRow({
    required this.isPm,
    required this.accent,
    required this.onChanged,
    this.alignRight = false,
  });

  final bool isPm;
  final Color accent;
  final ValueChanged<bool> onChanged;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final amSelected = !isPm;
    final pmSelected = isPm;

    Widget chip(String label, bool selected, bool pm) {
      return GestureDetector(
        onTap: () => onChanged(pm),
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? accent.withOpacity(0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? accent : const Color(0xFFB8BBC5),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment:
      alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        chip('AM', amSelected, false),
        const SizedBox(width: 8),
        chip('PM', pmSelected, true),
      ],
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    required this.accent,
  });

  final void Function(int digit) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final Color accent;

  Widget _numButton({
    int? digit,
    IconData? icon,
    String? label,
    VoidCallback? onTap,
  }) {
    Widget child;
    if (digit != null) {
      child = Text(
        '$digit',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
        ),
      );
    } else if (label != null) {
      child = Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
        ),
      );
    } else {
      child = Icon(icon, size: 18, color: const Color(0xFF8E8E93));
    }

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.4,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: digit == 0
                    ? accent.withOpacity(0.15)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _numButton(digit: 7, onTap: () => onDigit(7)),
            _numButton(digit: 8, onTap: () => onDigit(8)),
            _numButton(digit: 9, onTap: () => onDigit(9)),
          ],
        ),
        Row(
          children: [
            _numButton(digit: 4, onTap: () => onDigit(4)),
            _numButton(digit: 5, onTap: () => onDigit(5)),
            _numButton(digit: 6, onTap: () => onDigit(6)),
          ],
        ),
        Row(
          children: [
            _numButton(digit: 1, onTap: () => onDigit(1)),
            _numButton(digit: 2, onTap: () => onDigit(2)),
            _numButton(digit: 3, onTap: () => onDigit(3)),
          ],
        ),
        Row(
          children: [
            _numButton(label: 'C', onTap: onClear),
            _numButton(digit: 0, onTap: () => onDigit(0)),
            _numButton(
              icon: Icons.backspace_rounded,
              onTap: onBackspace,
            ),
          ],
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// DATE RANGE BOTTOM SHEET  (multi-select: year/month → days)
/// ---------------------------------------------------------------------------

enum _DatePickerMode { yearMonth, monthDays }

class DateRangeBottomSheet extends StatefulWidget {
  const DateRangeBottomSheet({
    super.key,
    required this.initialStart,
    this.initialEnd,
  });

  final DateTime initialStart;
  final DateTime? initialEnd;

  @override
  State<DateRangeBottomSheet> createState() => _DateRangeBottomSheetState();
}

class _DateRangeBottomSheetState extends State<DateRangeBottomSheet> {
  static const _accent = Color(0xFFFF6B6B);
  // static const _accent = Color(0xFFF6F6F6); // light gray

  late DateTime _displayMonth;
  late int _baseYear;

  /// All selected days (normalized to Y/M/D).
  late Set<DateTime> _selectedDays;

  _DatePickerMode _mode = _DatePickerMode.yearMonth;

  @override
  void initState() {
    super.initState();

    _selectedDays = <DateTime>{};

    final start = _dOnly(widget.initialStart);
    final end =
    widget.initialEnd != null ? _dOnly(widget.initialEnd!) : start;

    DateTime d = start;
    while (!d.isAfter(end)) {
      _selectedDays.add(d);
      d = d.add(const Duration(days: 1));
    }

    _displayMonth = DateTime(start.year, start.month, 1);
    _baseYear = start.year;
  }

  void _onMonthTap(int year, int month) {
    setState(() {
      _mode = _DatePickerMode.monthDays;
      _displayMonth = DateTime(year, month, 1);
    });
  }

  void _onDayTap(DateTime day) {
    final d = _dOnly(day);
    setState(() {
      if (_selectedDays.contains(d)) {
        _selectedDays.remove(d);
      } else {
        _selectedDays.add(d);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = min(constraints.maxWidth - 32, 360.0);

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Choose a date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F6F6),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          child: AnimatedSwitcher(
                            duration:
                            const Duration(milliseconds: 220),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(
                                    opacity: anim, child: child),
                            child: _mode == _DatePickerMode.yearMonth
                                ? _YearMonthView(
                              key:
                              const ValueKey('yearMonth'),
                              baseYear: _baseYear,
                              selectedDays: _selectedDays,
                              accent: _accent,
                              onMonthTap: _onMonthTap,
                            )
                                : _MonthDaysView(
                              key: const ValueKey('monthDays'),
                              displayMonth: _displayMonth,
                              selectedDays: _selectedDays,
                              accent: _accent,
                              onDayTap: _onDayTap,
                              onMonthChanged: (m) {
                                setState(() {
                                  _displayMonth = m;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// STEP 1: YEAR + MONTH CIRCLES

class _YearMonthView extends StatelessWidget {
  const _YearMonthView({
    super.key,
    required this.baseYear,
    required this.selectedDays,
    required this.accent,
    required this.onMonthTap,
  });

  final int baseYear;
  final Set<DateTime> selectedDays;
  final Color accent;
  final void Function(int year, int month) onMonthTap;

  bool _hasSelectionForMonth(int year, int month) {
    return selectedDays.any(
            (d) => d.year == year && d.month == month);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildYear(int year) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$year',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF737373),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (int month = 1; month <= 12; month++)
                _DateBubble(
                  label: '$month',
                  selectedStart:
                  _hasSelectionForMonth(year, month),
                  selectedEnd: false,
                  inRange: false,
                  accent: accent,
                  onTap: () => onMonthTap(year, month),
                ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildYear(baseYear),
        const SizedBox(height: 16),
        buildYear(baseYear + 1),
      ],
    );
  }
}

/// STEP 2: MONTH CALENDAR WITH DAYS (multi-select)

class _MonthDaysView extends StatefulWidget {
  const _MonthDaysView({
    super.key,
    required this.displayMonth,
    required this.selectedDays,
    required this.accent,
    required this.onDayTap,
    required this.onMonthChanged,
  });

  final DateTime displayMonth;
  final Set<DateTime> selectedDays;
  final Color accent;
  final void Function(DateTime day) onDayTap;
  final void Function(DateTime newMonth) onMonthChanged;

  @override
  State<_MonthDaysView> createState() => _MonthDaysViewState();
}

class _MonthDaysViewState extends State<_MonthDaysView> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.displayMonth;
  }

  bool _isSelected(DateTime day) =>
      widget.selectedDays.contains(_dOnly(day));

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.chevron_left_rounded,
                size: 22,
                color: Color(0xFFB8BBC5),
              ),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month - 1,
                    1,
                  );
                });
                widget.onMonthChanged(_focusedDay);
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                DateFormat('MMMM').format(_focusedDay),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A3A3A),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            TextButton(
              onPressed: () {
                if (widget.selectedDays.isEmpty) {
                  Navigator.pop(context);
                  return;
                }
                final days = widget.selectedDays.toList()
                  ..sort((a, b) => a.compareTo(b));
                Navigator.pop(
                  context,
                  DateRangeResult(days: days),
                );
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 0),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB8BBC5),
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Color(0xFFB8BBC5),
              ),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month + 1,
                    1,
                  );
                });
                widget.onMonthChanged(_focusedDay);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 260,
          child: TableCalendar(
            firstDay: DateTime(_focusedDay.year - 1, 1, 1),
            lastDay: DateTime(_focusedDay.year + 1, 12, 31),
            focusedDay: _focusedDay,
            headerVisible: false,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarFormat: CalendarFormat.month,
            rowHeight: 34,
            daysOfWeekHeight: 18,
            availableGestures: AvailableGestures.none,
            selectedDayPredicate: (day) => _isSelected(day),
            onPageChanged: (day) {
              setState(() {
                _focusedDay = DateTime(day.year, day.month, 1);
              });
              widget.onMonthChanged(_focusedDay);
            },
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              isTodayHighlighted: false,
              defaultTextStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w100,
                color: Color(0xFF808080),
              ),
              weekendTextStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w100,
                color: Color(0xFF808080),
              ),
              cellMargin: EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 4,
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w100,
                color: Color(0xFFFF6B6B),
              ),
              weekdayStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w100,
                color: Color(0xFFB8BBC5),
              ),
            ),
            onDaySelected: (day, _) => widget.onDayTap(day),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final bool isSunday =
                    day.weekday == DateTime.sunday;
                final bool isSelected = _isSelected(day);

                Color bg;
                Color textColor;

                if (isSelected) {
                  bg = accent;
                  textColor = Colors.white;
                } else {
                  bg = const Color(0xFFD5D5D5);
                  textColor = isSunday
                      ? accent
                      : const Color(0xFF707070);
                }

                return Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              },
              outsideBuilder: (context, day, focusedDay) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DateBubble extends StatelessWidget {
  const _DateBubble({
    required this.label,
    required this.selectedStart,
    required this.selectedEnd,
    required this.inRange,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selectedStart;
  final bool selectedEnd;
  final bool inRange;
  final Color accent; // still passed in, but we don't use it for color now
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool selected = selectedStart || selectedEnd;

    Color bg;
    Color textColor;

    // Style like the screenshot:
    //  - normal months: medium gray circle, white text
    //  - selected month: lighter gray circle, white text
    if (selected) {
      bg = const Color(0xFFF6F6F6); // light gray (selected)
      textColor = Colors.grey;
    } else {
      bg = const Color(0xFFBDBDBD); // normal month gray
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

