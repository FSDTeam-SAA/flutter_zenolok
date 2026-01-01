import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/common/constants/app_images.dart';
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
              image: Image.asset(
                AppImages.calender_icon2,
                width: 18,
                height: 18,
              ),
              label: 'Home',
              isActive: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _BottomItem(
              image: Image.asset(
                AppImages.event_icon,
                width: 18,
                height: 18,
              ),
              label: 'Events',
              isActive: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _BottomItem(
              image: Image.asset(
                AppImages.bar3_icon,
                width: 18,
                height: 18,
                fit: BoxFit.contain,

              ),
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
    required this.image,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final Image image;      // Image.asset(...)
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeTextColor   = Color(0xFF363538); // Dark gray from Figma
    const inactiveTextColor = Color(0xFFBDBDBD); // light gray

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(child: image),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,                 // 👈 Size 12px
                fontWeight: FontWeight.w500,  // 👈 Medium
                height: 16 / 12,              // 👈 Line height 16px
                letterSpacing: 0,             // 0%
                color: isActive
                    ? activeTextColor
                    : inactiveTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}





