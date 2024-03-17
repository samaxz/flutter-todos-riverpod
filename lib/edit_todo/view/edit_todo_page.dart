import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
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
      // builder: (context) => BlocProvider(
      //   create: (context) => EditTodoBloc(
      //     todosRepository: context.read<TodosRepository>(),
      //     initialTodo: initialTodo,
      //   ),
      //   child: const EditTodoPage(),
      // ),
      builder: (context) => EditTodoPage(initialTodo: initialTodo),
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
    ref.listen(editTodoNotifierProvider(initialTodo), (previous, next) {
      if (previous?.status != next.status && next.status == EditTodoStatus.success) {
        Navigator.of(context).pop();
        // log('did this get called?');
      }
    });
    return EditTodoView(initialTodo: initialTodo);
  }
}

// these cause issues with the text disappearing
// String title = 'awefasdfasdfasdf';
// String description = 'asdfasdfasdfasdfasdf';

class EditTodoView extends ConsumerStatefulWidget {
  const EditTodoView({
    super.key,
    this.initialTodo,
  });

  final Todo? initialTodo;

  @override
  ConsumerState createState() => _EditTodoViewState();
}

class _EditTodoViewState extends ConsumerState<EditTodoView> {
  // this is the default value
  // String title = '';
  // String description = '';

  // String determineTitle() {
  //   String title = '';
  //   if (widget.initialTodo != null) {
  //     title = widget.initialTodo!.title;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // final status = context.select((EditTodoBloc bloc) => bloc.state.status);
    // final isNewTodo = context.select(
    //   (EditTodoBloc bloc) => bloc.state.isNewTodo,
    // );
    // i think each of these should be takin in a specific todo
    final todoState = ref.watch(editTodoNotifierProvider(widget.initialTodo));
    final status = todoState.status;
    final isNewTodo = todoState.isNewTodo;
    final initialTodo = todoState.initialTodo;

    // log('is new todo: $isNewTodo');

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
            : () async {
                // TODO remove this as it's not needed
                final todo = Todo(
                  // title: initialTodo?.title ?? title,
                  // this only allows me to update the text once
                  // title: widget.initialTodo?.title ?? todoState.title,
                  // title: widget.initialTodo?.title ?? todoState.title,
                  // title: title.isEmpty ? 'todoState.title' : title,
                  // title: title.isEmpty ? 'title is empty' : 'title is not empty',
                  title: todoState.title,
                  // title: initialTodo.title == null ? ,
                  // description: initialTodo?.description ?? description,
                  // description: widget.initialTodo?.description ?? todoState.description,
                  // description: description,
                  // description: todoState.description,
                  description: todoState.description,
                  // title: title,
                  // description: description,
                  // isCompleted: true,
                );
                // log('title: $title');
                // log('description: $description');
                // log('initial todo title: ${initialTodo?.title}');
                // log('initial todo description: ${initialTodo?.description}');
                // log('todo title: ${todo.title}');
                // log('todo description: ${todo.description}');
                // log('todo state title: ${todoState.title}');
                // log('todo state description: ${todoState.description}');
                await ref
                    .read(editTodoNotifierProvider(widget.initialTodo).notifier)
                    // .submitTodo(initialTodo ?? todo);
                    .submitTodo(todo);
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
                _TitleField(
                  textFieldValue: (value) {
                    if (value.isEmpty) {
                      // title = todoState.title;
                      // if (widget.initialTodo != null) {
                      //   title = widget.initialTodo!.title;
                      // }
                      log('value is empty');
                    } else {
                      // title = value;
                    }
                  },
                  initialTodo: widget.initialTodo,
                ),
                _DescriptionField(
                  textFieldValue: (value) {
                    // description = value;
                  },
                  initialTodo: widget.initialTodo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleField extends ConsumerStatefulWidget {
  const _TitleField({
    required this.textFieldValue,
    this.initialTodo,
  });

  final ValueChanged<String> textFieldValue;
  final Todo? initialTodo;

  @override
  ConsumerState createState() => _TitleFieldState();
}

class _TitleFieldState extends ConsumerState<_TitleField> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialTodo?.title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // final state = context.watch<EditTodoBloc>().state;
    final state = ref.watch(editTodoNotifierProvider(widget.initialTodo));
    // final hintText = state.initialTodo?.title ?? '';
    final hintText = state.initialTodo?.title;
    // log('hint text for title: $hintText');
    // log('initial value: ${state.title}');

    return TextFormField(
      key: const Key('editTodoView_title_textFormField'),
      // initialValue: state.title,
      initialValue: hintText,
      // initialValue: 'asfasdfasdffs',
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
        // if (value.isNotEmpty)
        ref.read(editTodoNotifierProvider(widget.initialTodo).notifier).changeTitle(value);
        widget.textFieldValue(value);
        // if (value.trim().isNotEmpty) {
        //   title = value;
        // }
        // else if (initialTodo != null) {
        //   title = initialTodo!.title;
        // }
        // else {
        //   title = initialTodo?.title;
        // }
        // title = '${value}asdfasdf';
        // ref.read(editTodoNotifierProvider(initialTodo).notifier).changeTitle(title);
        // log('title is: $title');
      },
    );
  }
}

class _DescriptionField extends ConsumerWidget {
  const _DescriptionField({
    required this.textFieldValue,
    this.initialTodo,
  });

  final ValueChanged<String> textFieldValue;
  final Todo? initialTodo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    // final state = context.watch<EditTodoBloc>().state;
    final state = ref.watch(editTodoNotifierProvider(initialTodo));
    // final hintText = state.initialTodo?.description ?? '';
    final hintText = state.initialTodo?.description;
    // log('hint text for description: $hintText');

    return TextFormField(
      key: const Key('editTodoView_description_textFormField'),
      // initialValue: state.description,
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
        // context.read<EditTodoBloc>().add(EditTodoDescriptionChanged(value));
        ref.read(editTodoNotifierProvider(initialTodo).notifier).changeDescription(value);
        textFieldValue(value);
        // if (value.trim().isNotEmpty) {
        //   description = value;
        // } else if (initialTodo != null) {
        //   description = initialTodo!.description;
        // }
        // description = value;
        // ref.read(editTodoNotifierProvider(initialTodo).notifier).changeDescription(description);
        // log('description is: $description');
        // description = value ?? initialTodo?.description;
      },
    );
  }
}
