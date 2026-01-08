import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../controllers/event_totos_controller.dart';
import '../widgets/categories_grid.dart';
import '../widgets/event_todos_header.dart';
import '../widgets/scheduled_section.dart';


class TodosScreen extends GetView<EventTodosController> {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.refreshCategories(),
              controller.refreshScheduledTodos(),
            ]);
          },
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

