import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? drawer;
  final bool removePadding;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    this.appBar,
    this.drawer,
    required this.body,
    this.removePadding = false,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      appBar: appBar,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: removePadding ? 0 : 18),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
    );
  }
}
