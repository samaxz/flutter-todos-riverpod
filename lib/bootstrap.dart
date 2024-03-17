import 'dart:async';
import 'dart:developer';

// import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/app/app.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

void bootstrap({required TodosApi todosApi}) {
  FlutterError.onError = (details) {
    log(
      details.exceptionAsString(),
      stackTrace: details.stack,
    );
  };

  final todosRepository = TodosRepository(todosApi: todosApi);

  runApp(
    ProviderScope(
      overrides: [
        todosRepositoryProvider.overrideWithValue(todosRepository),
      ],
      child: const App(),
    ),
  );
}
