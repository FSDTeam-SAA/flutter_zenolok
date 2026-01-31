import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LetsJamRow extends StatelessWidget {
  const LetsJamRow({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const Color ghostColor = Color(0xFFD5D5D5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(19, 19),
              painter: _GhostPainter(color: ghostColor),
            ),
            const SizedBox(width: 6),
            Text(
              "Let's JAM",
              style: GoogleFonts.dongle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                height: 22 / 20,
                letterSpacing: 0,
                color: const Color(0xFFD5D5D5),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 19,
              color: ghostColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostPainter extends CustomPainter {
  _GhostPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color;

    final bodyRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.15,
      size.width * 0.7,
      size.height * 0.7,
    );

    final r = bodyRect.width / 2;
    final center = Offset(bodyRect.center.dx, bodyRect.top + r);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -3.14,
      3.14,
      false,
      paint,
    );

    canvas.drawLine(
      Offset(bodyRect.left, center.dy),
      Offset(bodyRect.left, bodyRect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(bodyRect.right, center.dy),
      Offset(bodyRect.right, bodyRect.bottom),
      paint,
    );

    final bottomPath = Path()..moveTo(bodyRect.left, bodyRect.bottom);
    final step = bodyRect.width / 3;
    bottomPath.quadraticBezierTo(
      bodyRect.left + step * 0.5,
      bodyRect.bottom - 3,
      bodyRect.left + step,
      bodyRect.bottom,
    );
    bottomPath.quadraticBezierTo(
      bodyRect.left + step * 1.5,
      bodyRect.bottom + 3,
      bodyRect.left + step * 2,
      bodyRect.bottom,
    );
    bottomPath.quadraticBezierTo(
      bodyRect.left + step * 2.5,
      bodyRect.bottom - 3,
      bodyRect.right,
      bodyRect.bottom,
    );
    canvas.drawPath(bottomPath, paint);

    final eyePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    final eyeY = center.dy - 2;
    final eyeOffsetX = bodyRect.width * 0.15;
    canvas.drawCircle(Offset(center.dx - eyeOffsetX, eyeY), 1.1, eyePaint);
    canvas.drawCircle(Offset(center.dx + eyeOffsetX, eyeY), 1.1, eyePaint);

    final mouthPath = Path()
      ..moveTo(center.dx - 3, center.dy + 2)
      ..quadraticBezierTo(
        center.dx,
        center.dy + 4,
        center.dx + 3,
        center.dy + 2,
      );
    canvas.drawPath(mouthPath, paint);
  }

  @override
  bool shouldRepaint(covariant _GhostPainter oldDelegate) =>
      oldDelegate.color != color;
}
