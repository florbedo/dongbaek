import 'package:dongbaek/blocs/progress_bloc.dart';
import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
import 'package:dongbaek/repositories/local/local_progress_repository.dart';
import 'package:dongbaek/repositories/local/local_schedule_repository.dart';
import 'package:dongbaek/repositories/progress_repository.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';
import 'package:dongbaek/utils/debug_handler.dart';
import 'package:dongbaek/views/schedule_list_page/schedule_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ScheduleRepository>(
          create: (BuildContext context) => LocalScheduleRepository(),
        ),
        RepositoryProvider<ProgressRepository>(
          create: (BuildContext context) => LocalProgressRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ScheduleBloc>(
            create: (BuildContext context) => ScheduleBloc(
              RepositoryProvider.of<ScheduleRepository>(context),
            ),
          ),
          BlocProvider<ProgressBloc>(
            create: (BuildContext context) => ProgressBloc(
              RepositoryProvider.of<ProgressRepository>(context),
            ),
          ),
          BlocProvider<TimerBloc>(
            create: (BuildContext context) => TimerBloc(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    DebugHandler.init();
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const ScheduleListPage(),
      },
    );
  }
}
