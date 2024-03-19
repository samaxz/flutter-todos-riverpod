import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/edit_todo/notifier/edit_todo_notifier.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:todos_repository/todos_repository.dart';

class EditTodoPage extends ConsumerWidget {
  const EditTodoPage({
    super.key,
    this.initialTodo,
  });

  final Todo? initialTodo;

  static Route<void> route({Todo? initialTodo}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => EditTodoPage(initialTodo: initialTodo),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(editTodoNotifierProvider(initialTodo), (previous, next) {
      if (previous?.status != next.status && next.status == EditTodoStatus.success) {
        Navigator.of(context).pop();
      }
    });

    final l10n = context.l10n;
    final todoState = ref.watch(editTodoNotifierProvider(initialTodo));
    final status = todoState.status;
    final isNewTodo = todoState.isNewTodo;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewTodo ? l10n.editTodoAddAppBarTitle : l10n.editTodoEditAppBarTitle,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.editTodoSaveButtonTooltip,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        onPressed: status.isLoadingOrSuccess
            ? null
            : () {
                ref.read(editTodoNotifierProvider(initialTodo).notifier).submitTodo();
              },
        child: status.isLoadingOrSuccess
            ? const CupertinoActivityIndicator()
            : const Icon(Icons.check_rounded),
      ),
      body: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _TitleField(initialTodo: initialTodo),
                _DescriptionField(initialTodo: initialTodo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleField extends ConsumerWidget {
  const _TitleField({this.initialTodo});

  final Todo? initialTodo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(editTodoNotifierProvider(initialTodo));
    final hintText = state.initialTodo?.title;

    return TextFormField(
      initialValue: hintText,
      key: const Key('editTodoView_title_textFormField'),
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editTodoTitleLabel,
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      onChanged: (value) {
        ref.read(editTodoNotifierProvider(initialTodo).notifier).changeTitle(value);
      },
    );
  }
}

class _DescriptionField extends ConsumerWidget {
  const _DescriptionField({this.initialTodo});

  final Todo? initialTodo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(editTodoNotifierProvider(initialTodo));
    final hintText = state.initialTodo?.description;

    return TextFormField(
      key: const Key('editTodoView_description_textFormField'),
      initialValue: hintText,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editTodoDescriptionLabel,
        hintText: hintText,
      ),
      maxLength: 300,
      maxLines: 7,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      onChanged: (value) {
        ref.read(editTodoNotifierProvider(initialTodo).notifier).changeDescription(value);
      },
    );
  }
}
