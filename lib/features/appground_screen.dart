import 'package:flutter/material.dart';
import 'event/presentation/screens/event_screen.dart';
import 'event_todos/presentation/screens/event_todos_screen.dart';
import 'home/presentation/screens/home.dart'; // where CalendarHomePage is
import 'package:flutter/cupertino.dart';

class AppGroundScreen extends StatefulWidget {
  const AppGroundScreen({super.key});

  @override
  State<AppGroundScreen> createState() => _AppGroundScreenState();
}

class _AppGroundScreenState extends State<AppGroundScreen> {
  int _currentIndex = 0;

  // your 3 tabs
  final _pages = const <Widget>[
    CalendarHomePage(),      // Home tab
    EventsScreen(),    // Events tab (replace later)
    EventTodosScreen(),     // Todos tab (replace later)
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // whole app background
      backgroundColor: Colors.white,

      // main content: switch between tabs
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),

      // bottom bar like design
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE0E0E0), width: 0.7),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomItem(
              icon: Icons.calendar_month_rounded,
              label: 'Home',
              isActive: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _BottomItem(
              icon: CupertinoIcons.square_grid_2x2,
              label: 'Events',
              isActive: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _BottomItem(
              icon: CupertinoIcons.list_bullet,
              label: 'Todos',
              isActive: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.black : Colors.black45;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// simple placeholders for second / third tab
class _EventsPlaceholder extends StatelessWidget {
  const _EventsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Events'));
  }
}

class _TodosPlaceholder extends StatelessWidget {
  const _TodosPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Todos'));
  }
}
