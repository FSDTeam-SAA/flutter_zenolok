import 'package:flutter/material.dart';

import '../../data/models/calendar_event.dart';
import '../screens/event_editor_screen.dart';

class FlatPlusButton extends StatelessWidget {
  const FlatPlusButton({
    super.key,
    required this.initialDate,
    required this.onAdd,
  });

  final DateTime initialDate;
  final void Function(CalendarEvent e) onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          final created = await Navigator.of(context).push<CalendarEvent>(
            PageRouteBuilder<CalendarEvent>(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  EventEditorScreen(initialDate: initialDate),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                final tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );

          if (created != null) onAdd(created);
        },
        child: SizedBox(
          width: 24,
          height: 24,
          child: CustomPaint(
            painter: _PlusPainter(
              color: const Color(0xFFCFCFCF),
              strokeWidth: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlusPainter extends CustomPainter {
  _PlusPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = size.center(Offset.zero);
    final halfLen = size.shortestSide * 0.35;

    canvas.drawLine(
      Offset(center.dx - halfLen, center.dy),
      Offset(center.dx + halfLen, center.dy),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy - halfLen),
      Offset(center.dx, center.dy + halfLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
