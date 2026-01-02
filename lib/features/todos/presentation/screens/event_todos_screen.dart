import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../controllers/event_totos_controller.dart';
import '../widgets/categories_grid.dart';
import '../widgets/event_todos_header.dart';
import '../widgets/scheduled_section.dart';


class EventTodosScreen extends GetView<EventTodosController> {
  const EventTodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshCategories(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EventTodosHeader(),
                  const SizedBox(height: 24),
                  const ScheduledSection(),
                  const SizedBox(height: 24),
                  // Categories Grid with title
                  Obx(
                    () => controller.categories.isEmpty
                        ? const SizedBox.shrink()
                        : const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 16),
                            child: Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                  ),
                  CategoriesGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

