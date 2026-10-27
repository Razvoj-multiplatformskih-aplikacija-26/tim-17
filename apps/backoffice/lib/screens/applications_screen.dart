import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prijave kandidata')),
      body: const EmptyView(title: 'Tabela i kanban prijava stižu uskoro.'),
    );
  }
}
