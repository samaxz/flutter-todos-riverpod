import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/stats/notifier/stats_notifier.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(statsNotifierProvider.notifier).requestSubscription(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(statsNotifierProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsAppBarTitle),
      ),
      body: Column(
        children: [
          ListTile(
            key: const Key('statsView_completedTodos_listTile'),
            leading: const Icon(Icons.check_rounded),
            title: Text(l10n.statsCompletedTodoCountLabel),
            trailing: Text(
              '${state.completedTodos}',
              style: textTheme.headlineSmall,
            ),
          ),
          ListTile(
            key: const Key('statsView_activeTodos_listTile'),
            leading: const Icon(Icons.radio_button_unchecked_rounded),
            title: Text(l10n.statsActiveTodoCountLabel),
            trailing: Text(
              '${state.activeTodos}',
              style: textTheme.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }
}
