import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleDetailDrawer extends StatelessWidget {
  static const errorDrawer = Drawer(child: Text("ERROR"));

  final Schedule _schedule;

  const ScheduleDetailDrawer(this._schedule, {super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Text(_schedule.title, style: Theme.of(context).textTheme.titleMedium),
          Text("Goal: ${_schedule.goal}"),
          Text("Repeat: ${_schedule.repeatInfo}"),
          Text("From: ${_schedule.startDateTime}"),
          Text("To: ${_schedule.dueDateTime}"),
          Text("Finished: ${_schedule.finishDateTime}"),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<ScheduleBloc>(context).add(CompleteSchedule(_schedule.id, DateTime.now()));
            },
            child: const Text("Complete"),
          ),
        ],
      ),
    );
  }
}
