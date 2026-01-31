import 'package:flutter/material.dart';

class BaseEventCard extends StatelessWidget {
  const BaseEventCard({
    super.key,
    required this.child,
    this.marginTop = 8,
    this.height,
    this.verticalPadding = 10,
  });

  final Widget child;
  final double marginTop;
  final double? height;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.fromLTRB(12, marginTop, 12, 0),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
