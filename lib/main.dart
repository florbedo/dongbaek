import 'package:dongbaek/blocs/progress_bloc.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ScheduleBloc, List<Schedule>>(builder: (context, List<Schedule> schedules) {
        return BlocBuilder<ProgressBloc, Map<int, List<Progress>>>(
            builder: (context, Map<int, List<Progress>> progressMap) {
          final tiles = schedules.map((schedule) {
            final repeatInfo = schedule.repeatInfo;
            Text subtitle;
            if (schedule.repeatInfo is RepeatPerDay) {
              subtitle = Text('${(repeatInfo as RepeatPerDay).repeatCount} / ${(repeatInfo).daysOfWeek} // ${progressMap[schedule.id]}');
            } else {
              subtitle = Text('${(repeatInfo as RepeatPerWeek).repeatCount} per week');
            }
            return ListTile(
              title: Text(schedule.title),
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
    );
  }
}
