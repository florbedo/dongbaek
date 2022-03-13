import 'package:dongbaek/blocs/progress_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_schedule_page.dart';
import 'blocs/schedule_bloc.dart';
import 'models/progress.dart';
import 'models/schedule.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ScheduleBloc>(
          create: (BuildContext context) => ScheduleBloc(),
        ),
        BlocProvider<ProgressBloc>(
          create: (BuildContext context) => ProgressBloc(),
        ),
        BlocProvider<TimerBloc>(
          create: (BuildContext context) => TimerBloc(),
        ),
      ],
      child: const MyApp(),
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
        '/': (context) => const MyHomePage(),
        '/addSchedule': (context) => const AddSchedulePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _currentDate = DateTimeUtils.truncateToDay(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimerBloc, DateTime>(
      listenWhen: (before, current) {
        return before.day != current.day;
      },
      listener: (context, DateTime dateTime) {
        setState(() {
          _currentDate = DateTimeUtils.truncateToDay(dateTime);
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("${_currentDate}"),
        ),
        body: BlocBuilder<ScheduleBloc, List<Schedule>>(builder: (context, List<Schedule> schedules) {
          return BlocBuilder<ProgressBloc, Map<int, Progress>>(builder: (context, Map<int, Progress> progressMap) {
            final tiles = schedules.map((schedule) {
              final repeatInfo = schedule.repeatInfo;
              Text subtitle;
              if (schedule.repeatInfo is RepeatPerDay) {
                subtitle = Text('${progressMap[schedule.id]?.completeTimes.length} / ${(repeatInfo as RepeatPerDay)
                    .repeatCount}');
              } else {
                subtitle = Text('${progressMap[schedule.id]?.completeTimes.length} / ${(repeatInfo as RepeatPerWeek)
                    .repeatCount}');
              }
              return ListTile(
                title: Text(schedule.title + " by " + (schedule.repeatInfo is RepeatPerDay ? "Daily" : "Weekly")),
                subtitle: subtitle,
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    context.read<ScheduleBloc>().add(RemoveScheduleEvent(schedule.id));
                  },
                ),
                onLongPress: () {
                  context.read<ProgressBloc>().add(AddProgressEvent(schedule.id, DateTime.now()));
                },
              );
            }).toList();
            return ListView.builder(
              itemCount: tiles.length,
              itemBuilder: (BuildContext context, int index) => Card(child: tiles[index]),
            );
          });
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.pushNamed(context, "/addSchedule");
          },
          tooltip: 'Add',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
