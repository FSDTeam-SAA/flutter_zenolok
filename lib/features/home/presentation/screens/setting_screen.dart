import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/common/widgets/app_scaffold.dart';
import 'package:get/get.dart';
import '../../../auth/presentation/controller/auth_controller.dart';
import 'bricks_manage_screen.dart';
import 'todos_categories_manage_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return AppScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Settings items
                    _buildSettingTile(
                      icon: Icons.verified_rounded,
                      title: 'Bricks Manage',
                      // subtitle: 'Remove Ads & Unlock Features',
                      onTap: () {
                        Get.to(() => const BricksManageScreen());
                      },
                    ),
                    _buildSettingTile(
                      icon: Icons.remove_red_eye_outlined,
                      title: 'Todos Categories Manage',
                      onTap: () {
                        Get.to(() => const TodosCategoriesManageScreen());
                      },
                    ),
                    _buildSettingTile(
                      icon: Icons.calendar_today_outlined,
                      title: 'Edit Event',
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notification, Badge',
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),

                    // Support section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Support',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildSettingTile(
                      icon: Icons.chat_bubble_outline,
                      title: 'Feedback',
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      icon: Icons.help_outline,
                      title: 'Help',
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      icon: Icons.support_agent_outlined,
                      title: 'Settings Assistant',
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      icon: Icons.restore_outlined,
                      title: 'Restore Events',
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),

                    // Support minical section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Support minical',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildSettingTile(
                      icon: Icons.share_outlined,
                      title: 'Share App',
                      onTap: () {},
                    ),

                    const SizedBox(height: 32),

                    // Logout button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Show custom confirmation dialog
                            final confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.6),
                              builder: (context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111111),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      24,
                                      24,
                                      18,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Logout',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Are you sure you want to logout?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Color(0xFF22C55E),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                'Logout',
                                                style: TextStyle(
                                                  color: Color(0xFFEF4444),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            if (confirmed == true) {
                              await authController.logout();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.black87, size: 22),
            ),

            const SizedBox(width: 16),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),

            // Chevron arrow
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}
