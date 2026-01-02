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
    return const AppScaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventTodosHeader(),
              SizedBox(height: 24),
              ScheduledSection(),
              SizedBox(height: 24),
              CategoriesGrid(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
