import 'package:flutter/material.dart';

class EventTodosHeader extends StatelessWidget {
  const EventTodosHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'Todos',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: 0.2,
            ),
          ),
        ),
        _CircleIconButton(icon: Icons.search),
        SizedBox(width: 8),
        _CircleIconButton(icon: Icons.notifications_none),
        SizedBox(width: 8),
        _CircleIconButton(icon: Icons.settings_outlined),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;

  const _CircleIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Icon(
        icon,
        size: 18,
        color: Colors.black87,
      ),
    );
  }
}
