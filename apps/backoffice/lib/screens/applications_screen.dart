import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../models/board_item.dart';
import '../shortcuts.dart';
import '../widgets/applications_list.dart';
import '../widgets/applications_table.dart';
import '../widgets/board_header.dart';
import '../widgets/bulk_action_bar.dart';
import '../widgets/detail_panel.dart';
import '../widgets/kanban_board.dart';
import '../widgets/shortcuts_dialog.dart';
import '../widgets/sidebar.dart';

enum _Layout { wide, medium, narrow }

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  List<BoardItem> _items = const [];
  BoardView _view = BoardView.table;
  ApplicationStatus? _statusFilter;
  JobPostingId? _postingFilter;
  JobApplicationId? _cursor;
  final _checked = <JobApplicationId>{};
  final _search = TextEditingController();
  final _searchFocus = FocusNode(debugLabel: 'Pretraga');
  final _boardFocus = FocusNode(debugLabel: 'Prijave');
  final _listScroll = ScrollController();
  final _cardKeys = <JobApplicationId, GlobalKey>{};
  double _rowExtent = ApplicationsTable.rowExtent;

  @override
  void initState() {
    super.initState();
    _boardFocus.addListener(_onFocusChanged);
    _searchFocus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    _boardFocus.dispose();
    _listScroll.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  bool get _typing => _searchFocus.hasFocus;

  List<JobPosting> get _postings {
    final seen = <JobPostingId>{};
    return [
      for (final item in _items)
        if (seen.add(item.posting.id)) item.posting,
    ];
  }

  bool _matches(BoardItem item) {
    if (_postingFilter != null && item.posting.id != _postingFilter)
      return false;
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return item.candidate.name.toLowerCase().contains(query) ||
        item.posting.title.toLowerCase().contains(query) ||
        item.posting.city.toLowerCase().contains(query);
  }

  List<BoardItem> get _matching => _items.where(_matches).toList()
    ..sort(
      (a, b) => b.application.appliedAt.compareTo(a.application.appliedAt),
    );

  List<BoardItem> get _visible => [
    for (final item in _matching)
      if (_statusFilter == null || item.status == _statusFilter) item,
  ];

  BoardItem? get _current =>
      _items.where((item) => item.id == _cursor).firstOrNull;

  GlobalKey _keyFor(JobApplicationId id) =>
      _cardKeys.putIfAbsent(id, GlobalKey.new);

  void _select(JobApplicationId? id) {
    setState(() => _cursor = id);
    _boardFocus.requestFocus();
    if (id != null)
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(id));
  }

  void _reveal(JobApplicationId id) {
    if (!mounted) return;
    if (_view == BoardView.kanban) {
      final context = _cardKeys[id]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: const Duration(milliseconds: 150),
        );
      }
      return;
    }
    if (!_listScroll.hasClients) return;
    final index = _visible.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final position = _listScroll.position;
    final top = index * _rowExtent;
    final bottom = top + _rowExtent;
    const duration = Duration(milliseconds: 120);
    if (top < position.pixels) {
      _listScroll.animateTo(top, duration: duration, curve: Curves.easeOut);
    } else if (bottom > position.pixels + position.viewportDimension) {
      _listScroll.animateTo(
        bottom - position.viewportDimension,
        duration: duration,
        curve: Curves.easeOut,
      );
    }
  }

  void _move(int delta) {
    final visible = _visible;
    if (visible.isEmpty) return;
    var list = visible;
    if (_view == BoardView.kanban) {
      final status = _current?.status;
      final column = [
        for (final item in visible)
          if (item.status == status) item,
      ];
      list = column.isEmpty
          ? [
              for (final item in visible)
                if (item.status == visible.first.status) item,
            ]
          : column;
    }
    final index = list.indexWhere((item) => item.id == _cursor);
    final next = index < 0 ? 0 : (index + delta).clamp(0, list.length - 1);
    _select(list[next].id);
  }

  void _moveColumn(int delta) {
    if (_view != BoardView.kanban) return;
    final visible = _visible;
    if (visible.isEmpty) return;
    final columns = [
      for (final status in ApplicationStatus.values)
        [
          for (final item in visible)
            if (item.status == status) item,
        ],
    ];
    final current = _current;
    final column = current == null
        ? -delta
        : ApplicationStatus.values.indexOf(current.status);
    final row = current == null
        ? 0
        : columns[column]
              .indexWhere((item) => item.id == current.id)
              .clamp(0, 1 << 20);
    for (var c = column + delta; c >= 0 && c < columns.length; c += delta) {
      if (columns[c].isNotEmpty) {
        _select(columns[c][row.clamp(0, columns[c].length - 1)].id);
        return;
      }
    }
  }

  void _toggleCheck([JobApplicationId? id]) {
    final target = id ?? _cursor;
    if (target == null) return;
    setState(
      () => _checked.contains(target)
          ? _checked.remove(target)
          : _checked.add(target),
    );
  }

  void _toggleAll() {
    final ids = {for (final item in _visible) item.id};
    if (ids.isEmpty) return;
    setState(
      () => _checked.containsAll(ids)
          ? _checked.removeAll(ids)
          : _checked.addAll(ids),
    );
  }

  bool _canMove(JobApplicationId id, ApplicationStatus to) {
    final item = _items.where((item) => item.id == id).firstOrNull;
    return item != null && nextStatuses(item.status).contains(to);
  }

  Future<void> _changeStatus(
    ApplicationStatus to, {
    Set<JobApplicationId>? only,
  }) async {
    final bulk = only == null && _checked.isNotEmpty;
    final targets = only ?? (bulk ? {..._checked} : {?_cursor});
    if (targets.isEmpty) return;
    if (to == ApplicationStatus.rejected &&
        !await _confirmReject(targets.length))
      return;
    if (!mounted) return;
    final changed = targets.where((id) => _canMove(id, to)).length;
    setState(() {
      _items = [
        for (final item in _items)
          if (targets.contains(item.id) &&
              nextStatuses(item.status).contains(to))
            item.withStatus(to)
          else
            item,
      ];
      if (bulk) _checked.clear();
    });
    _boardFocus.requestFocus();
    final skipped = targets.length - changed;
    final message = changed == 0
        ? 'Ova promena nije moguća za ${targets.length == 1 ? 'izabranu prijavu' : 'izabrane prijave'}.'
        : '${to.doneLabel}: $changed ${pluralize(changed, one: 'prijava', few: 'prijave', many: 'prijava')}'
              '${skipped > 0 ? ' · preskočeno $skipped' : ''}';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), width: 440));
  }

  Future<bool> _confirmReject(int count) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          count == 1
              ? 'Odbiti prijavu?'
              : 'Odbiti $count ${pluralize(count, one: 'prijavu', few: 'prijave', many: 'prijava')}?',
        ),
        content: const Text('Odbijena prijava se više ne može prihvatiti.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Otkaži'),
          ),
          FilledButton(
            autofocus: true,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Odbij'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _escape() {
    if (_typing) {
      _boardFocus.requestFocus();
    } else if (_checked.isNotEmpty) {
      setState(_checked.clear);
    } else if (_cursor != null) {
      _select(null);
    }
  }

  void _focusSearch() {
    _searchFocus.requestFocus();
    _search.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _search.text.length,
    );
  }

  void _setView(BoardView view) {
    setState(() => _view = view);
    final cursor = _cursor;
    if (cursor != null)
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(cursor));
  }

  void _showShortcuts() => showDialog<void>(
    context: context,
    builder: (context) => const ShortcutsDialog(),
  );

  Map<Type, Action<Intent>> _actions() {
    bool notTyping() => !_typing;
    GuardedCallbackAction<T> guarded<T extends Intent>(
      VoidCallback callback, {
      bool Function()? enabled,
    }) => GuardedCallbackAction<T>(
      enabled: enabled ?? notTyping,
      onInvoke: (_) => callback(),
    );
    return {
      NextItemIntent: guarded<NextItemIntent>(() => _move(1)),
      PreviousItemIntent: guarded<PreviousItemIntent>(() => _move(-1)),
      NextColumnIntent: guarded<NextColumnIntent>(() => _moveColumn(1)),
      PreviousColumnIntent: guarded<PreviousColumnIntent>(
        () => _moveColumn(-1),
      ),
      ToggleCheckIntent: guarded<ToggleCheckIntent>(
        _toggleCheck,
        enabled: () => _boardFocus.hasPrimaryFocus,
      ),
      CheckAllIntent: guarded<CheckAllIntent>(_toggleAll),
      AcceptIntent: guarded<AcceptIntent>(
        () => _changeStatus(ApplicationStatus.accepted),
      ),
      RejectIntent: guarded<RejectIntent>(
        () => _changeStatus(ApplicationStatus.rejected),
      ),
      CompleteIntent: guarded<CompleteIntent>(
        () => _changeStatus(ApplicationStatus.completed),
      ),
      BoardEscapeIntent: CallbackAction<BoardEscapeIntent>(
        onInvoke: (_) => _escape(),
      ),
      FocusSearchIntent: guarded<FocusSearchIntent>(_focusSearch),
      ShowTableIntent: guarded<ShowTableIntent>(
        () => _setView(BoardView.table),
      ),
      ShowKanbanIntent: guarded<ShowKanbanIntent>(
        () => _setView(BoardView.kanban),
      ),
      ShowShortcutsIntent: guarded<ShowShortcutsIntent>(_showShortcuts),
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final layout = width >= 1200
            ? _Layout.wide
            : (width >= 900 ? _Layout.medium : _Layout.narrow);
        final narrow = layout == _Layout.narrow;
        _rowExtent = narrow
            ? ApplicationsList.rowExtent
            : ApplicationsTable.rowExtent;
        final current = _current;
        final matching = _matching;
        final visible = _visible;
        final counts = {
          for (final status in ApplicationStatus.values)
            status: matching.where((item) => item.status == status).length,
        };
        final showFocus = _boardFocus.hasFocus && !_typing;
        final empty = _items.isEmpty
            ? const EmptyView(
                icon: Icons.inbox_outlined,
                title: 'Još nema prijava',
                message: 'Kad studenti počnu da se prijavljuju na oglase, prijave će se pojaviti ovde.',
              )
            : const EmptyView(
                icon: Icons.search_off_rounded,
                title: 'Nema prijava za ove filtere',
                message: 'Promeni status, oglas ili pretragu.',
              );

        final board = switch (_view) {
          BoardView.kanban => KanbanBoard(
            items: visible,
            cursor: _cursor,
            checked: _checked,
            showFocus: showFocus,
            onTap: _select,
            onToggle: _toggleCheck,
            canMove: _canMove,
            onMove: (id, to) => _changeStatus(to, only: {id}),
            keyFor: _keyFor,
            horizontalPadding: narrow ? 16 : 32,
          ),
          BoardView.table when narrow => ApplicationsList(
            items: visible,
            cursor: _cursor,
            checked: _checked,
            showFocus: showFocus,
            controller: _listScroll,
            onTap: _select,
            onToggle: _toggleCheck,
            empty: empty,
          ),
          BoardView.table => ApplicationsTable(
            items: visible,
            cursor: _cursor,
            checked: _checked,
            showFocus: showFocus,
            controller: _listScroll,
            onTap: _select,
            onToggle: _toggleCheck,
            onToggleAll: _toggleAll,
            empty: empty,
          ),
        };

        Widget main = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BoardHeader(
              total: _items.length,
              postings: _postings.length,
              search: _search,
              searchFocus: _searchFocus,
              onQuery: (_) => setState(() {}),
              view: _view,
              onView: _setView,
              onShortcuts: _showShortcuts,
              compact: narrow,
            ),
            BoardToolbar(
              statusFilter: _statusFilter,
              counts: counts,
              onStatus: (status) => setState(() => _statusFilter = status),
              postings: _postings,
              postingFilter: _postingFilter,
              onPosting: (posting) => setState(() => _postingFilter = posting),
              compact: narrow,
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: board),
                  if (_checked.isNotEmpty)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 24,
                      child: Center(
                        child: BulkActionBar(
                          count: _checked.length,
                          onAccept: () =>
                              _changeStatus(ApplicationStatus.accepted),
                          onReject: () =>
                              _changeStatus(ApplicationStatus.rejected),
                          onComplete: () =>
                              _changeStatus(ApplicationStatus.completed),
                          onClear: () => setState(_checked.clear),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
        if (narrow && current != null) {
          main = DetailPanel(
            item: current,
            fullWidth: true,
            onClose: () => _select(null),
            onChange: (to) => _changeStatus(to, only: {current.id}),
          );
        }

        return Shortcuts(
          shortcuts: boardShortcuts(),
          child: Actions(
            actions: _actions(),
            child: Focus(
              focusNode: _boardFocus,
              autofocus: true,
              child: Scaffold(
                body: SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!narrow)
                        Sidebar(
                          compact: layout == _Layout.medium,
                          pendingCount: counts[ApplicationStatus.pending] ?? 0,
                        ),
                      Expanded(child: main),
                      if (!narrow && current != null)
                        SizedBox(
                          width: layout == _Layout.wide ? 400 : 340,
                          child: DetailPanel(
                            item: current,
                            onClose: () => _select(null),
                            onChange: (to) =>
                                _changeStatus(to, only: {current.id}),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
