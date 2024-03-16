import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:flutter_todos/edit_todo/providers/edit_todo_provider.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:todos_repository/todos_repository.dart';

class EditTodoPage extends ConsumerWidget {
  const EditTodoPage({super.key});

  static Route<void> route({Todo? initialTodo}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      // builder: (context) => BlocProvider(
      //   create: (context) => EditTodoBloc(
      //     todosRepository: context.read<TodosRepository>(),
      //     initialTodo: initialTodo,
      //   ),
      //   child: const EditTodoPage(),
      // ),

      builder: (context) => const EditTodoPage(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return BlocListener<EditTodoBloc, EditTodoState>(
    //   listenWhen: (previous, current) =>
    //       previous.status != current.status && current.status == EditTodoStatus.success,
    //   listener: (context, state) => Navigator.of(context).pop(),
    //   child: const EditTodoView(),
    // );

    ref.listen(editTodoProvider, (previous, next) {
      if (previous?.status != next.status && next.status == EditTodoStatus.success) {
        Navigator.of(context).pop();
      }
    });
    return const EditTodoView();
  }
}

class EditTodoView extends ConsumerWidget {
  const EditTodoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // final status = context.select((EditTodoBloc bloc) => bloc.state.status);
    // final isNewTodo = context.select(
    //   (EditTodoBloc bloc) => bloc.state.isNewTodo,
    // );
    final status = ref.watch(editTodoProvider).status;
    final isNewTodo = ref.watch(editTodoProvider).isNewTodo;

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
            // : () => context.read<EditTodoBloc>().add(const EditTodoSubmitted()),
            : () => ref.read(editTodoProvider.notifier).submitTodo(),
        child: status.isLoadingOrSuccess
            ? const CupertinoActivityIndicator()
            : const Icon(Icons.check_rounded),
      ),
      body: const CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [_TitleField(), _DescriptionField()],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleField extends ConsumerWidget {
  const _TitleField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // final state = context.watch<EditTodoBloc>().state;
    final state = ref.watch(editTodoProvider);
    final hintText = state.initialTodo?.title ?? '';

    return TextFormField(
      key: const Key('editTodoView_title_textFormField'),
      initialValue: state.title,
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
        // context.read<EditTodoBloc>().add(EditTodoTitleChanged(value));
        ref.read(editTodoProvider.notifier).changeTitle(value);
      },
    );
  }
}

class _DescriptionField extends ConsumerWidget {
  const _DescriptionField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    // final state = context.watch<EditTodoBloc>().state;
    final state = ref.watch(editTodoProvider);
    final hintText = state.initialTodo?.description ?? '';

    return TextFormField(
      key: const Key('editTodoView_description_textFormField'),
      initialValue: state.description,
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
        // context.read<EditTodoBloc>().add(EditTodoDescriptionChanged(value));
        ref.read(editTodoProvider.notifier).changeDescription(value);
      },
    );
  }
}
