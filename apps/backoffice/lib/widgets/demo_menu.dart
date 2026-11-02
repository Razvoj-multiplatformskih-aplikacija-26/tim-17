import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dependencies.dart';

enum _DemoAction { failNext, emptyNext, reload }

class DemoMenu extends StatelessWidget {
  const DemoMenu({super.key});

  void _run(BuildContext context, _DemoAction action) {
    final board = context.read<BackofficeDependencies>().fakeBoard!;
    final messenger = ScaffoldMessenger.of(context);
    switch (action) {
      case _DemoAction.failNext:
        board.failNextRequest();
        messenger.showSnackBar(const SnackBar(content: Text('Sledeći zahtev će pasti.'), width: 440));
      case _DemoAction.emptyNext:
        board.answerEmptyNext();
        messenger.showSnackBar(const SnackBar(content: Text('Sledeći odgovor će biti prazan.'), width: 440));
      case _DemoAction.reload:
        context.read<ApplicationsBoardBloc>().add(const BoardRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.read<BackofficeDependencies>().fakeBoard == null) return const SizedBox.shrink();
    return PopupMenuButton<_DemoAction>(
      tooltip: 'Demo',
      icon: const Icon(Icons.science_outlined),
      onSelected: (action) => _run(context, action),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _DemoAction.failNext,
          child: ListTile(leading: Icon(Icons.wifi_off_rounded), title: Text('Greška u sledećem zahtevu')),
        ),
        PopupMenuItem(
          value: _DemoAction.emptyNext,
          child: ListTile(leading: Icon(Icons.inbox_outlined), title: Text('Prazan sledeći odgovor')),
        ),
        PopupMenuItem(
          value: _DemoAction.reload,
          child: ListTile(leading: Icon(Icons.refresh_rounded), title: Text('Ponovo učitaj')),
        ),
      ],
    );
  }
}
