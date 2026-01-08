import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class TimeRangeResult {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRangeResult({required this.start, required this.end});
}

class DateRangeResult {
  final List<DateTime> days;

  DateRangeResult({required List<DateTime> days})
    : days = days.map(_dOnly).toList()..sort((a, b) => a.compareTo(b));

  DateTime get start => days.first;
  DateTime get end => days.last;
}

/// ---------------------------------------------------------------------------
/// TIME RANGE BOTTOM SHEET ( FIXED TIME INPUT WITHOUT UI CHANGE)
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

  int? _selectedDurationMinutes;

  @override
  void initState() {
    super.initState();
    _startDigits = '';
    _endDigits = '';
    _startIsPm = widget.initialStart.period == DayPeriod.pm;
    _endIsPm = widget.initialEnd.period == DayPeriod.pm;
  }

  TimeOfDay _digitsToTime(String digits, bool isPm, TimeOfDay fallback) {
    final raw = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return fallback;

    int h12 = 1;
    int m = 0;

    if (raw.length == 1) {
      h12 = int.parse(raw[0]);
      m = 0;
    } else if (raw.length == 2) {
      final val = int.parse(raw);
      if (val <= 12) {
        h12 = val;
        m = 0;
      } else {
        h12 = int.parse(raw[0]);
        m = int.parse(raw[1]) * 10;
      }
    } else if (raw.length == 3) {
      h12 = int.parse(raw[0]);
      m = int.parse(raw.substring(1, 3));
    } else {
      final d4 = raw.substring(0, 4);
      int hh = int.parse(d4.substring(0, 2));
      int mm = int.parse(d4.substring(2, 4));

      if (hh > 12) {
        hh = int.parse(d4[0]);
        mm = int.parse(d4.substring(1, 3));
      }

      h12 = hh;
      m = mm;
    }

    h12 = h12.clamp(1, 12);
    m = m.clamp(0, 59);

    final hour24 = isPm ? (h12 % 12) + 12 : (h12 % 12);
    return TimeOfDay(hour: hour24, minute: m);
  }

  String _timeToDigits(TimeOfDay t) {
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final h = hour12.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h$m';
  }

  void _clearEndSelection() {
    _selectedDurationMinutes = null;
    _endDigits = '';
  }

  void _onDigitTap(int digit) {
    setState(() {
      if (_editingStart) {
        if (_startDigits.length < 4) {
          _startDigits += digit.toString();
        }
        _clearEndSelection();
      } else {
        if (_endDigits.length < 4) {
          _endDigits += digit.toString();
        }
        _selectedDurationMinutes = null;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_editingStart) {
        if (_startDigits.isNotEmpty) {
          _startDigits = _startDigits.substring(0, _startDigits.length - 1);
        }
        _clearEndSelection();
      } else {
        if (_endDigits.isNotEmpty) {
          _endDigits = _endDigits.substring(0, _endDigits.length - 1);
        }
        _selectedDurationMinutes = null;
      }
    });
  }

  void _onClear() {
    setState(() {
      if (_editingStart) {
        _startDigits = '';
        _clearEndSelection();
      } else {
        _endDigits = '';
        _selectedDurationMinutes = null;
      }
    });
  }

  void _applyDuration(int minutes) {
    if (_startDigits.isEmpty) return;

    final start = _digitsToTime(_startDigits, _startIsPm, widget.initialStart);
    final startDate = DateTime(2020, 1, 1, start.hour, start.minute);
    final endDate = startDate.add(Duration(minutes: minutes));
    final endTime = TimeOfDay(hour: endDate.hour, minute: endDate.minute);

    setState(() {
      _selectedDurationMinutes = minutes;
      _editingStart = false;
      _endIsPm = endTime.period == DayPeriod.pm;
      _endDigits = _timeToDigits(endTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasUsableStart = _startDigits.isNotEmpty;

    return SafeArea(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = min(constraints.maxWidth - 32, 360.0);

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cardWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
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
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
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
                                    onTap: () =>
                                        setState(() => _editingStart = true),
                                    child: _TimeDigitDisplay(
                                      rawDigits: _startDigits,
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
                                    onTap: () =>
                                        setState(() => _editingStart = false),
                                    child: _TimeDigitDisplay(
                                      rawDigits: _endDigits,
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
                                      _clearEndSelection();
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
                                      _selectedDurationMinutes = null;
                                    }),
                                    alignRight: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _NumberPad(
                                    onDigit: _onDigitTap,
                                    onBackspace: _onBackspace,
                                    onClear: _onClear,
                                    accent: _accent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 56,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _DurationChip(
                                        label: '1h',
                                        minutes: 60,
                                        accent: _accent,
                                        selected:
                                            _selectedDurationMinutes == 60,
                                        enabled: hasUsableStart,
                                        onTap: () => _applyDuration(60),
                                      ),
                                      const SizedBox(height: 8),
                                      _DurationChip(
                                        label: '1.5h',
                                        minutes: 90,
                                        accent: _accent,
                                        selected:
                                            _selectedDurationMinutes == 90,
                                        enabled: hasUsableStart,
                                        onTap: () => _applyDuration(90),
                                      ),
                                      const SizedBox(height: 8),
                                      _DurationChip(
                                        label: '2h',
                                        minutes: 120,
                                        accent: _accent,
                                        selected:
                                            _selectedDurationMinutes == 120,
                                        enabled: hasUsableStart,
                                        onTap: () => _applyDuration(120),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              minimumSize: const Size(0, 0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.minutes,
    required this.accent,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final int minutes;
  final Color accent;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? accent : const Color(0xFFD8D8D8);
    final textColor = selected ? Colors.white : const Color(0xFF8E8E93);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? bg : const Color(0xFFE0E0E0),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: enabled ? textColor : const Color(0xFFB8BBC5),
          ),
        ),
      ),
    );
  }
}

class _TimeDigitDisplay extends StatelessWidget {
  const _TimeDigitDisplay({
    required this.rawDigits,
    required this.isActive,
    required this.accent,
    this.alignRight = false,
  });

  final String rawDigits;
  final bool isActive;
  final Color accent;
  final bool alignRight;

  ({String digits4, Set<int> filled}) _normalize(String raw) {
    final d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.isEmpty) return (digits4: '', filled: <int>{});

    if (d.length == 1) {
      return (digits4: '0${d[0]}00', filled: {1});
    }
    if (d.length == 2) {
      final val = int.tryParse(d) ?? 0;
      if (val <= 12) {
        final hh = d.padLeft(2, '0');
        return (digits4: '${hh}00', filled: {0, 1});
      } else {
        return (digits4: '0${d[0]}${d[1]}0', filled: {1, 2});
      }
    }
    if (d.length == 3) {
      return (digits4: '0$d', filled: {1, 2, 3});
    }
    return (digits4: d.substring(0, 4), filled: {0, 1, 2, 3});
  }

  Widget _bubble(String text, bool filled) {
    final highlight = isActive && filled;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlight ? accent.withOpacity(0.18) : const Color(0xFFE5E5E5),
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
    final norm = _normalize(rawDigits);
    final d4 = norm.digits4.isEmpty ? '0000' : norm.digits4;

    final innerRow = Row(
      mainAxisAlignment: alignRight
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        _bubble(d4[0], norm.filled.contains(0)),
        const SizedBox(width: 4),
        _bubble(d4[1], norm.filled.contains(1)),
        const SizedBox(width: 4),
        const Text(
          ':',
          style: TextStyle(fontSize: 16, color: Color(0xFFB8BBC5)),
        ),
        const SizedBox(width: 4),
        _bubble(d4[2], norm.filled.contains(2)),
        const SizedBox(width: 4),
        _bubble(d4[3], norm.filled.contains(3)),
      ],
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(0.18) : Colors.transparent,
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
      mainAxisAlignment: alignRight
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
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
            _numButton(icon: Icons.backspace_rounded, onTap: onBackspace),
          ],
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// DATE RANGE BOTTOM SHEET (two taps = range)   (same UI)
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

  late DateTime _displayMonth;
  late int _baseYear;

  late Set<DateTime> _selectedDays;
  _DatePickerMode _mode = _DatePickerMode.yearMonth;

  @override
  void initState() {
    super.initState();

    _selectedDays = <DateTime>{};

    final start = _dOnly(widget.initialStart);
    final end = widget.initialEnd != null ? _dOnly(widget.initialEnd!) : start;

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = min(constraints.maxWidth - 32, 360.0);

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cardWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 10,
                        ),
                        child: Row(
                          children:[
                            Image.asset(AppImages.dateicon,
                            color: Colors.black87,
                                width: 16,
                                height: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Choose a date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 0),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: _mode == _DatePickerMode.yearMonth
                              ? _YearMonthView(
                                  key: const ValueKey('yearMonth'),
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
                                  onMonthChanged: (m) {
                                    setState(() => _displayMonth = m);
                                  },
                                  onDone: () {
                                    if (_selectedDays.isEmpty) {
                                      Navigator.pop(context);
                                      return;
                                    }
                                    final days = _selectedDays.toList()
                                      ..sort((a, b) => a.compareTo(b));
                                    Navigator.pop(
                                      context,
                                      DateRangeResult(days: days),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

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
    return selectedDays.any((d) => d.year == year && d.month == month);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildYearSection(int year) {
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
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = _hasSelectionForMonth(year, month);

              return GestureDetector(
                onTap: () => onMonthTap(year, month),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? accent : const Color(0xFFBFBFBF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$month',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildYearSection(baseYear),
        const SizedBox(height: 20),
        buildYearSection(baseYear + 1),
      ],
    );
  }
}

class _MonthDaysView extends StatefulWidget {
  const _MonthDaysView({
    super.key,
    required this.displayMonth,
    required this.selectedDays,
    required this.accent,
    required this.onMonthChanged,
    required this.onDone,
  });

  final DateTime displayMonth;
  final Set<DateTime> selectedDays;
  final Color accent;
  final void Function(DateTime newMonth) onMonthChanged;
  final VoidCallback onDone;

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

  bool _isSelected(DateTime day) => widget.selectedDays.contains(_dOnly(day));

  void _handleDayTap(DateTime day) {
    final d = _dOnly(day);

    setState(() {
      final set = widget.selectedDays;

      if (set.isEmpty) {
        set.add(d);
      } else if (set.length == 1) {
        final first = set.first;
        set.clear();

        final start = first.isBefore(d) ? first : d;
        final end = first.isBefore(d) ? d : first;

        DateTime cursor = start;
        while (!cursor.isAfter(end)) {
          set.add(cursor);
          cursor = cursor.add(const Duration(days: 1));
        }
      } else {
        set
          ..clear()
          ..add(d);
      }
    });
  }

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
              onPressed: widget.onDone,
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
            firstDay: DateTime(_focusedDay.year - 2, 1, 1),
            lastDay: DateTime(_focusedDay.year + 2, 12, 31),
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
              cellMargin: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
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
            onDaySelected: (day, _) => _handleDayTap(day),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                final bool isSunday = day.weekday == DateTime.sunday;
                final bool isSelected = _isSelected(day);

                final Color bg = isSelected ? accent : const Color(0xFFD5D5D5);
                final Color textColor = isSelected
                    ? Colors.white
                    : (isSunday ? accent : const Color(0xFF707070));

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
              outsideBuilder: (context, day, focusedDay) =>
                  const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
