import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

bool get usesCommandKey => defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.iOS;

String get commandKeyLabel => usesCommandKey ? '⌘' : 'Ctrl';

class GuardedCallbackAction<T extends Intent> extends CallbackAction<T> {
  GuardedCallbackAction({required this.enabled, required super.onInvoke});

  final bool Function() enabled;

  @override
  bool isEnabled(T intent) => enabled();
}

class NextItemIntent extends Intent {
  const NextItemIntent();
}

class PreviousItemIntent extends Intent {
  const PreviousItemIntent();
}

class NextColumnIntent extends Intent {
  const NextColumnIntent();
}

class PreviousColumnIntent extends Intent {
  const PreviousColumnIntent();
}

class ToggleCheckIntent extends Intent {
  const ToggleCheckIntent();
}

class CheckAllIntent extends Intent {
  const CheckAllIntent();
}

class AcceptIntent extends Intent {
  const AcceptIntent();
}

class RejectIntent extends Intent {
  const RejectIntent();
}

class CompleteIntent extends Intent {
  const CompleteIntent();
}

class BoardEscapeIntent extends Intent {
  const BoardEscapeIntent();
}

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class ShowTableIntent extends Intent {
  const ShowTableIntent();
}

class ShowKanbanIntent extends Intent {
  const ShowKanbanIntent();
}

class ShowShortcutsIntent extends Intent {
  const ShowShortcutsIntent();
}

Map<ShortcutActivator, Intent> boardShortcuts() => {
  const SingleActivator(LogicalKeyboardKey.arrowDown): const NextItemIntent(),
  const SingleActivator(LogicalKeyboardKey.keyJ): const NextItemIntent(),
  const SingleActivator(LogicalKeyboardKey.arrowUp): const PreviousItemIntent(),
  const SingleActivator(LogicalKeyboardKey.keyK): const PreviousItemIntent(),
  const SingleActivator(LogicalKeyboardKey.arrowRight): const NextColumnIntent(),
  const SingleActivator(LogicalKeyboardKey.arrowLeft): const PreviousColumnIntent(),
  const SingleActivator(LogicalKeyboardKey.space): const ToggleCheckIntent(),
  SingleActivator(LogicalKeyboardKey.keyA, meta: usesCommandKey, control: !usesCommandKey): const CheckAllIntent(),
  const SingleActivator(LogicalKeyboardKey.keyP): const AcceptIntent(),
  const SingleActivator(LogicalKeyboardKey.keyO): const RejectIntent(),
  const SingleActivator(LogicalKeyboardKey.keyZ): const CompleteIntent(),
  const SingleActivator(LogicalKeyboardKey.escape): const BoardEscapeIntent(),
  SingleActivator(LogicalKeyboardKey.keyF, meta: usesCommandKey, control: !usesCommandKey): const FocusSearchIntent(),
  const CharacterActivator('/'): const FocusSearchIntent(),
  const SingleActivator(LogicalKeyboardKey.digit1): const ShowTableIntent(),
  const SingleActivator(LogicalKeyboardKey.digit2): const ShowKanbanIntent(),
  const CharacterActivator('?'): const ShowShortcutsIntent(),
};

final class ShortcutDescription {
  const ShortcutDescription(this.keys, this.description);

  final List<String> keys;
  final String description;
}

List<ShortcutDescription> shortcutDescriptions() => [
  const ShortcutDescription(['↑', '↓'], 'Prethodna / sledeća prijava'),
  const ShortcutDescription(['J', 'K'], 'Isto, bez strelica'),
  const ShortcutDescription(['←', '→'], 'Susedna kolona u kanbanu'),
  const ShortcutDescription(['Space'], 'Označi prijavu za masovnu promenu'),
  ShortcutDescription([commandKeyLabel, 'A'], 'Označi sve prikazane'),
  const ShortcutDescription(['P'], 'Prihvati'),
  const ShortcutDescription(['O'], 'Odbij'),
  const ShortcutDescription(['Z'], 'Označi kao završenu'),
  const ShortcutDescription(['Esc'], 'Poništi izbor / zatvori detalj'),
  ShortcutDescription([commandKeyLabel, 'F'], 'Pretraga (ili /)'),
  const ShortcutDescription(['1', '2'], 'Tabela / kanban'),
  const ShortcutDescription(['?'], 'Pregled prečica'),
];
