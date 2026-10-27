import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poslovi')),
      body: const EmptyView(title: 'Oglasi stižu uskoro.'),
    );
  }
}
