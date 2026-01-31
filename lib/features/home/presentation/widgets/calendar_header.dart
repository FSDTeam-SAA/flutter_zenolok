import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/constants/app_images.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/search_screen.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/setting_screen.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/notification_screen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime focusedDate;
  final VoidCallback onTitleTap;

  const CalendarHeader({
    super.key,
    required this.focusedDate,
    required this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          InkWell(
            onTap: onTitleTap,
            borderRadius: BorderRadius.circular(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMM').format(focusedDate).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dongle(
                    fontWeight: FontWeight.w300,
                    // Light (300)
                    fontSize: 70,
                    // Figma size
                    height: 22 / 70,
                    // line-height 22px
                    letterSpacing: 0,
                    color: const Color(0xFF363538), // #363538
                  ),
                ),
                const SizedBox(width: 8),
                Transform.translate(
                  offset: const Offset(0, -10),
                  // adjust vertical position if needed
                  child: Text(
                    DateFormat('yyyy').format(focusedDate),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dongle(
                      fontWeight: FontWeight.w400,
                      // Regular (400)
                      fontSize: 36,
                      // Figma size
                      height: 22 / 36,
                      // line-height 22px
                      letterSpacing: 0,
                      color: const Color(0xFFB6B5B5), // Gray4 #B6B5B5
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            iconSize: 28,
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const MinimalSearchScreen(),
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
            },
            icon: Image.asset(
              AppImages.search_icon,
              width: 28.67,
              height: 28.67,
              fit: BoxFit.contain,
              color: Colors.black,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          Stack(
            children: [
              IconButton(
                iconSize: 28,
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const NotificationScreen(),
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
                },
                icon: Image.asset(
                  AppImages.vector_icon,
                  width: 28.67,
                  height: 28.67,
                  fit: BoxFit.contain,
                  color: Colors.black87,
                  // colorBlendMode: BlendMode.srcIn,
                  filterQuality: FilterQuality.none, // makes edges sharper
                  isAntiAlias: false,
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5757),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            iconSize: 28,
            onPressed: () {
              Get.to(() => const SettingsScreen());
            },
            icon: Image.asset(
              AppImages.setting_icon,
              width: 28.67,
              height: 28.67,
              fit: BoxFit.contain,
              color: Colors.black,
              // colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
