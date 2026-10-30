import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: Frosted(
        top: true,
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (index) => shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.work_outline_rounded),
              selectedIcon: Icon(Icons.work_rounded),
              label: 'Poslovi',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment_rounded),
              label: 'Moje prijave',
            ),
          ],
        ),
      ),
    );
  }
}
