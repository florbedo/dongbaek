import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_schedule_page.dart';
import 'blocs/schedule_bloc.dart';
import 'models/schedule.dart';

void main() {
  runApp(BlocProvider(
    create: (BuildContext context) => ScheduleBloc(),
    child: const MyApp(),
  ));
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
      body: BlocBuilder<ScheduleBloc, List<Schedule>>(builder: (BuildContext context, List<Schedule> schedules) {
        final tiles = schedules
            .map((schedule) => ListTile(
                  title: Text(schedule.title),
                  subtitle: Text('Content of ${schedule.title}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      context.read<ScheduleBloc>().add(RemoveScheduleEvent(schedule.id));
                    },
                  ),
                ))
            .toList();
        return ListView.builder(
          itemCount: tiles.length,
          itemBuilder: (BuildContext context, int index) => Card(child: tiles[index]),
        );
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
