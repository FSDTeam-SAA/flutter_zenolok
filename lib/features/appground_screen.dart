import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'event/presentation/screens/event_screen.dart';
import 'todos/presentation/screens/event_todos_screen.dart';
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
        // child: IndexedStack(
        //   index: _currentIndex,
        //   children: _pages,
        // ),
        child: _pages[_currentIndex],
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
    const borderInactive = Color(0xFFE0E0E0);
    const borderActive = Color(0xFF4C9BFF);
    const iconInactive = Color(0xFFB8B8B8);
    const iconActive = Color(0xFF4C9BFF);

    // Figma text colors
    const activeTextColor = Color(0xFF363538);  // Dark gray
    const inactiveTextColor = Color(0xFFBDBDBD);

    final textColor = isActive ? activeTextColor : inactiveTextColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 24×24 framed icon (as before)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                // border: Border.all(
                //   color: isActive ? borderActive : borderInactive,
                //   width: 1.5,
                // ),
              ),
              child: Icon(
                icon,
                size: 14,
                color: isActive ? iconActive : iconInactive,
              ),
            ),
            const SizedBox(height: 4),

            // 🔹 Figma typography for label
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,                 // Size 12px
                fontWeight: FontWeight.w500,  // Medium 500
                height: 16 / 12,              // Line-height 16px
                letterSpacing: 0,             // 0%
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



