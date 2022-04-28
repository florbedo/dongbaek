import 'package:dongbaek/blocs/snapshot_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
import 'package:dongbaek/repositories/local/local_progress_repository.dart';
import 'package:dongbaek/repositories/local/local_schedule_repository.dart';
import 'package:dongbaek/repositories/progress_repository.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';
import 'package:dongbaek/views/add_schedule_page.dart';
import 'package:dongbaek/views/schedule_list_of_day_page.dart';
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
          BlocProvider<SnapshotBloc>(
            create: (BuildContext context) => SnapshotBloc(
              RepositoryProvider.of<ScheduleRepository>(context),
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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ScheduleListOfDayPage(),
        '/addSchedule': (context) => const AddSchedulePage(),
      },
    );
  }
}
