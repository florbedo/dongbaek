import 'package:dongbaek/add_schedule_page.dart';
import 'package:dongbaek/blocs/app_state.dart';
import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:flutter/material.dart';

void main() {
  final scheduleBloc = ScheduleBloc();
  final blocProvider = BlocProvider(scheduleBloc);

  runApp(AppStateContainer(child: const MyApp(), blocProvider: blocProvider));
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
  late ScheduleBloc _bloc;

  @override
  void didChangeDependencies() {
    _bloc = AppStateContainer.of(context).blocProvider.scheduleBloc;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: _bloc.schedules,
          initialData: const <Schedule>[],
          builder:
              (BuildContext context, AsyncSnapshot<List<Schedule>> snapshot) {
            final tiles = snapshot.data
                    ?.map((schedule) => ListTile(
                          title: Text(schedule.title),
                          subtitle: Text('Content of ${schedule.title}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              _bloc.removeScheduleSink
                                  .add(RemoveScheduleEvent(schedule.id));
                            },
                          ),
                        ))
                    .toList() ??
                [];
            return ListView.builder(
                itemCount: tiles.length,
                itemBuilder: (BuildContext context, int index) =>
                    Card(child: tiles[index]));
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
