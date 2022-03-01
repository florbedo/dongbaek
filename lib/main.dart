import 'package:dongbaek/add_schedule_page.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
  final List<Schedule> _schedules = [];

  void _addSchedule(Schedule schedule) {
    setState(() {
      _schedules.add(schedule);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: _schedules.length,
          itemBuilder: (BuildContext context, int index) => Card(
              child: ListTile(
                  title: Text(_schedules[index].title),
                  subtitle: Text('Content of ${_schedules[index].title}'),
                  trailing: const Icon(Icons.more_vert)))),
      floatingActionButton: FloatingActionButton(
        // onPressed: _incrementCounter,
        onPressed: () async {
          final schedule = await Navigator.pushNamed(context, "/addSchedule") as Schedule;
          _addSchedule(schedule);
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
