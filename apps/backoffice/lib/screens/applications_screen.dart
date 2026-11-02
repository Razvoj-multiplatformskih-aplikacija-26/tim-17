import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../models/board_item.dart';
import '../widgets/demo_menu.dart';
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
  BoardView _view = BoardView.table;
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

  ApplicationsBoardBloc get _bloc => context.read<ApplicationsBoardBloc>();

  BoardLoaded? get _loaded => switch (_bloc.state) {
    final BoardLoaded state => state,
    _ => null,
  };

  BoardFilters get _filters => _loaded?.filters ?? const BoardFilters();

  void _filter(BoardFilters filters) => _bloc.add(BoardFiltersChanged(filters));

  List<BoardItem> get _visible => [
    for (final record in _loaded?.visible ?? const <ApplicationRecord>[]) BoardItem(record),
  ];

  BoardItem? get _current => switch (_cursor) {
    final id? => switch (_loaded?.find(id)) {
      final record? => BoardItem(record),
      null => null,
    },
    null => null,
  };

  GlobalKey _keyFor(JobApplicationId id) => _cardKeys.putIfAbsent(id, GlobalKey.new);

  void _select(JobApplicationId? id) {
    setState(() => _cursor = id);
    _boardFocus.requestFocus();
    if (id != null) WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(id));
  }

  void _reveal(JobApplicationId id) {
    if (!mounted) return;
    if (_view == BoardView.kanban) {
      final context = _cardKeys[id]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context, alignment: 0.5, duration: const Duration(milliseconds: 150));
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
      _listScroll.animateTo(bottom - position.viewportDimension, duration: duration, curve: Curves.easeOut);
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
    final column = current == null ? -delta : ApplicationStatus.values.indexOf(current.status);
    final row = current == null ? 0 : columns[column].indexWhere((item) => item.id == current.id).clamp(0, 1 << 20);
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
    setState(() => _checked.contains(target) ? _checked.remove(target) : _checked.add(target));
  }

  void _toggleAll() {
    final ids = {for (final item in _visible) item.id};
    if (ids.isEmpty) return;
    setState(() => _checked.containsAll(ids) ? _checked.removeAll(ids) : _checked.addAll(ids));
  }

  bool _canMove(JobApplicationId id, ApplicationStatus to) => _loaded?.canMove(id, to) ?? false;

  Future<void> _changeStatus(ApplicationStatus to, {Set<JobApplicationId>? only}) async {
    if (_loaded?.isBusy ?? true) return;
    final bulk = only == null && _checked.isNotEmpty;
    final targets = only ?? (bulk ? {..._checked} : {?_cursor});
    if (targets.isEmpty) return;
    if (to == ApplicationStatus.rejected && !await _confirmReject(targets.length)) return;
    if (!mounted) return;
    _bloc.add(StatusChangeRequested(targets, to));
    if (bulk) setState(_checked.clear);
    _boardFocus.requestFocus();
  }

  void _showNotice(BoardNotice notice) {
    _bloc.add(const BoardNoticeAcknowledged());
    String applications(int count) => pluralize(count, one: 'prijava', few: 'prijave', many: 'prijava');
    final message = switch (notice) {
      StatusChanged(:final to, :final changed, :final skipped) =>
        '${to.doneLabel}: $changed ${applications(changed)}${skipped > 0 ? ' · preskočeno $skipped' : ''}',
      StatusChangeSkipped(:final count) =>
        'Ova promena nije moguća za ${count == 1 ? 'izabranu prijavu' : 'izabrane prijave'}.',
      StatusChangeRejected(:final error) => error.message,
      StatusChangeFailed() => 'Promena nije sačuvana. Proveri internet vezu i pokušaj ponovo.',
    };
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Otkaži')),
          FilledButton(
            autofocus: true,
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
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
    _search.selection = TextSelection(baseOffset: 0, extentOffset: _search.text.length);
  }

  void _setView(BoardView view) {
    setState(() => _view = view);
    final cursor = _cursor;
    if (cursor != null) WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(cursor));
  }

  void _showShortcuts() => showDialog<void>(context: context, builder: (context) => const ShortcutsDialog());

  Map<Type, Action<Intent>> _actions() {
    bool notTyping() => !_typing;
    GuardedCallbackAction<T> guarded<T extends Intent>(VoidCallback callback, {bool Function()? enabled}) =>
        GuardedCallbackAction<T>(enabled: enabled ?? notTyping, onInvoke: (_) => callback());
    return {
      NextItemIntent: guarded<NextItemIntent>(() => _move(1)),
      PreviousItemIntent: guarded<PreviousItemIntent>(() => _move(-1)),
      NextColumnIntent: guarded<NextColumnIntent>(() => _moveColumn(1)),
      PreviousColumnIntent: guarded<PreviousColumnIntent>(() => _moveColumn(-1)),
      ToggleCheckIntent: guarded<ToggleCheckIntent>(_toggleCheck, enabled: () => _boardFocus.hasPrimaryFocus),
      CheckAllIntent: guarded<CheckAllIntent>(_toggleAll),
      AcceptIntent: guarded<AcceptIntent>(() => _changeStatus(ApplicationStatus.accepted)),
      RejectIntent: guarded<RejectIntent>(() => _changeStatus(ApplicationStatus.rejected)),
      CompleteIntent: guarded<CompleteIntent>(() => _changeStatus(ApplicationStatus.completed)),
      BoardEscapeIntent: CallbackAction<BoardEscapeIntent>(onInvoke: (_) => _escape()),
      FocusSearchIntent: guarded<FocusSearchIntent>(_focusSearch),
      ShowTableIntent: guarded<ShowTableIntent>(() => _setView(BoardView.table)),
      ShowKanbanIntent: guarded<ShowKanbanIntent>(() => _setView(BoardView.kanban)),
      ShowShortcutsIntent: guarded<ShowShortcutsIntent>(_showShortcuts),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApplicationsBoardBloc, ApplicationsBoardState>(
      listenWhen: (previous, current) => current is BoardLoaded && current.notice != null,
      listener: (context, state) => _showNotice((state as BoardLoaded).notice!),
      builder: (context, state) => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final layout = width >= 1200 ? _Layout.wide : (width >= 900 ? _Layout.medium : _Layout.narrow);
          final narrow = layout == _Layout.narrow;
          _rowExtent = narrow ? ApplicationsList.rowExtent : ApplicationsTable.rowExtent;
          final loaded = state is BoardLoaded ? state : null;
          final current = _current;
          final visible = _visible;
          final counts = loaded?.counts ?? const <ApplicationStatus, int>{};
          final postings = loaded?.postings ?? const <JobPosting>[];
          final filters = _filters;
          final showFocus = _boardFocus.hasFocus && !_typing;
          const empty = EmptyView(
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

          final content = switch (state) {
            BoardLoading() => const LoadingView(),
            BoardFailure() => FailureView(onRetry: () => _bloc.add(const BoardRetried())),
            BoardEmpty() => const EmptyView(
              icon: Icons.inbox_outlined,
              title: 'Još nema prijava',
              message: 'Kad studenti počnu da se prijavljuju na oglase, prijave će se pojaviti ovde.',
            ),
            BoardLoaded() => board,
          };

          Widget main = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BoardHeader(
                total: loaded?.records.length ?? 0,
                postings: postings.length,
                search: _search,
                searchFocus: _searchFocus,
                onQuery: (query) => _filter(filters.copyWith(query: query)),
                view: _view,
                onView: _setView,
                onShortcuts: _showShortcuts,
                demo: const DemoMenu(),
                compact: narrow,
              ),
              BoardToolbar(
                statusFilter: filters.status,
                counts: counts,
                onStatus: (status) => _filter(filters.copyWith(status: () => status)),
                postings: postings,
                postingFilter: filters.jobId,
                onPosting: (posting) => _filter(filters.copyWith(jobId: () => posting)),
                compact: narrow,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: content),
                    if (_checked.isNotEmpty)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 24,
                        child: Center(
                          child: BulkActionBar(
                            count: _checked.length,
                            onAccept: () => _changeStatus(ApplicationStatus.accepted),
                            onReject: () => _changeStatus(ApplicationStatus.rejected),
                            onComplete: () => _changeStatus(ApplicationStatus.completed),
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
              actions: loaded?.actionsFor(current.id) ?? const {},
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
                              onChange: (to) => _changeStatus(to, only: {current.id}),
                              actions: loaded?.actionsFor(current.id) ?? const {},
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
      ),
    );
  }
}
