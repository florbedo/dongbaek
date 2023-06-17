import 'package:dongbaek/blocs/progress_bloc.dart';
import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/services/progress_service.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:dongbaek/views/components/add_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'schedule_tiles.dart';

class ScheduleListPage extends StatefulWidget {
  const ScheduleListPage({Key? key}) : super(key: key);

  @override
  State<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  DateTime _currentDate = DateTimeUtils.truncateToDay(DateTime.now());
  Schedule? _selectedSchedule;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimerBloc, DateTime>(
      listenWhen: (before, current) {
        return before.day != current.day;
      },
      listener: (context, DateTime dateTime) {
        setState(() {
          _currentDate = DateTimeUtils.truncateToDay(dateTime);
          BlocProvider.of<ScheduleBloc>(context).add(RefreshSchedules(dateTime: _currentDate));
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              "${_currentDate.year}/${_currentDate.month}/${_currentDate.day}(${DateTimeUtils.getDayOfWeek(_currentDate)})"),
        ),
        endDrawer: Drawer(child: Text(_selectedSchedule?.title ?? "ERROR")),
        body: BlocBuilder<ScheduleBloc, List<Schedule>>(
          builder: (context, List<Schedule> schedules) {
            final scheduleIds = schedules.map((schedule) => schedule.id).toList();
            BlocProvider.of<ProgressBloc>(context).add(RefreshProgresses(scheduleIds, _currentDate));
            return BlocBuilder<ProgressBloc, Map<ScheduleId, Progress>>(
                builder: (context, Map<ScheduleId, Progress> progressMap) {
              if (progressMap.length != schedules.length) {
                return const Text("Loading...");
              }
              final tiles = schedules.map((schedule) {
                final progress = progressMap[schedule.id]!;
                return ScheduleTile(
                  schedule,
                  progress,
                  completed: ProgressService.isDoneProgress(schedule.goal, progress),
                  onTap: () {
                    _setScheduleAndOpenEndDrawer(context, schedule);
                  },
                );
              }).toList();
              return ListView(
                  children: List<Widget>.generate(
                        tiles.length,
                        (index) => Card(child: tiles[index]),
                      ) +
                      [const AddScheduleCard()] +
                      [Container(height: 80)]);
            });
          },
        ),
      ),
    );
  }

  void _setScheduleAndOpenEndDrawer(BuildContext context, Schedule schedule) {
    setState(() {
      _selectedSchedule = schedule;
    });
    Scaffold.of(context).openEndDrawer();
  }
}
