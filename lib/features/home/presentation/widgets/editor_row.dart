import 'package:flutter/material.dart';

class EditorRow extends StatelessWidget {
  const EditorRow({
    super.key,
    required this.icon,
    required this.label,
    required this.labelColor,
    this.trailing,
    this.onTap,
    this.expandMiddle = false,
    this.middleChild,
  });

  final IconData icon;
  final String label;
  final Color labelColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool expandMiddle;
  final Widget? middleChild;

  @override
  Widget build(BuildContext context) {
    final middle =
        middleChild ??
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: labelColor),
            const SizedBox(width: 12),
            if (expandMiddle) Expanded(child: middle) else middle,
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
      ),
    );
  }
}
