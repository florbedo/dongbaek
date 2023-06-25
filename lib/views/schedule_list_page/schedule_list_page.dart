import 'package:dongbaek/blocs/progress_bloc.dart';
import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/services/progress_service.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:dongbaek/views/components/add_schedule_card.dart';
import 'package:dongbaek/views/schedule_list_page/schedule_detail_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'schedule_tile.dart';

class ScheduleListPage extends StatefulWidget {
  const ScheduleListPage({super.key});

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
          title: Container(alignment: Alignment.centerLeft, child: const Text("동백")),
          actions: <Widget>[Container()],
        ),
        endDrawer:
            _selectedSchedule == null ? ScheduleDetailDrawer.errorDrawer : ScheduleDetailDrawer(_selectedSchedule!),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.create),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360, maxHeight: 400),
                      child: const AddScheduleCard(),
                    ),
                  );
                });
          },
        ),
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
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${_currentDate.year}년 ${_currentDate.month}월 ${_currentDate.day}일 (${DateTimeUtils.getDayOfWeek(_currentDate)})",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: tiles.map((tile) => Card(child: tile)).toList(),
                    ),
                  ),
                ],
              );
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
