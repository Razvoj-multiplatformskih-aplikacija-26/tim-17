import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moje prijave')),
      body: const EmptyView(title: 'Još nemate prijava.'),
    );
  }
}
