import 'dart:developer' as dev;

import 'package:dartx/dartx.dart';
import 'package:dongbaek/blocs/progress_bloc.dart';
import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:dongbaek/views/components/add_schedule_card.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleListOfDayPage extends StatefulWidget {
  const ScheduleListOfDayPage({Key? key}) : super(key: key);

  @override
  State<ScheduleListOfDayPage> createState() => _ScheduleListOfDayPageState();
}

class _ScheduleListOfDayPageState extends State<ScheduleListOfDayPage> {
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
          BlocProvider.of<ScheduleBloc>(context).add(RefreshSchedules(dateTime: _currentDate));
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              "${_currentDate.year}/${_currentDate.month}/${_currentDate.day}(${DateTimeUtils.getDayOfWeek(_currentDate)})"),
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
              final scheduleAndProgressPairs = schedules.map((schedule) {
                final progress = progressMap[schedule.id]!;
                return Pair(schedule, progress);
              });
              final todoTiles = scheduleAndProgressPairs
                  .filter((pair) => !pair.second.isCompleted(pair.first))
                  .map((pair) => _buildScheduleProgressTile(pair.first, pair.second))
                  .toList();
              final completedTiles = scheduleAndProgressPairs
                  .filter((pair) => pair.second.isCompleted(pair.first))
                  .map((pair) => _buildScheduleProgressTile(pair.first, pair.second))
                  .toList();
              return ListView(
                  children: List<Widget>.generate(
                        todoTiles.length,
                        (index) => Card(child: todoTiles[index]),
                      ) +
                      [
                        ExpandableNotifier(
                          child: Expandable(
                            collapsed: ExpandableButton(
                              child: const Card(
                                child: ListTile(
                                  leading: Icon(Icons.expand_more),
                                  title: Text(
                                    "Completed items",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                            expanded: Column(
                              children: [
                                    ExpandableButton(
                                      child: const Card(
                                        child: ListTile(
                                          leading: Icon(Icons.expand_less),
                                          title: Text(
                                            "Completed items",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ].cast<Widget>() +
                                  List<Widget>.generate(
                                    completedTiles.length,
                                    (index) => Card(child: completedTiles[index]),
                                  ),
                            ),
                          ),
                        ),
                      ] +
                      [const AddScheduleCard()] +
                      [Container(height: 80)]);
            });
          },
        ),
      ),
    );
  }

  bool _isCompletedSchedule(Schedule schedule, Progress progress) {
    if (schedule.isFinished()) {
      return true;
    }
    bool isLastProgress = false;
    switch (schedule.repeatInfo) {
      case Unrepeated _:
        isLastProgress = true;
      case PeriodicRepeat r:
        final dueDateTime = schedule.dueDateTime;
        if (dueDateTime == null) {
          return false;
        }
        final lastProgressStartDateTime = dueDateTime.subtract(r.periodDuration);
        isLastProgress = DateTime.now().isAfter(lastProgressStartDateTime);
      default:
        return false;
    }
    return isLastProgress && progress.isCompleted(schedule);
  }

  Widget _buildScheduleProgressTile(Schedule schedule, Progress progress) {
    if (progress is QuantityProgress) {
      return _buildQuantityScheduleTile(schedule, progress);
    }
    if (progress is DurationProgress) {
      return _buildDurationScheduleTile(schedule, progress);
    }
    throw UnimplementedError();
  }

  Widget _buildQuantityScheduleTile(Schedule schedule, QuantityProgress progress) {
    final repeatInfo = schedule.repeatInfo;
    final startDateStr = DateTimeUtils.formatDate(progress.startDateTime);
    final endDateStr = progress.endDateTime != null ? DateTimeUtils.formatDate(progress.endDateTime!) : "continue";
    final periodStr = _describeRepeatInfo(repeatInfo);
    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.plus_one),
        onPressed: () {
          final newProgress = progress.diff(1);
          context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
          if (!_isCompletedSchedule(schedule, progress) && _isCompletedSchedule(schedule, newProgress)) {
            context.read<ScheduleBloc>().add(CompleteSchedule(schedule.id, DateTime.now()));
          }
        },
      ),
      title: Text("${schedule.title} (${_describeProgress(schedule.goal, progress)})"),
      subtitle: Text("$periodStr ($startDateStr ~ $endDateStr)"),
    );
  }

  Widget _buildDurationScheduleTile(Schedule schedule, DurationProgress progress) {
    final repeatInfo = schedule.repeatInfo;
    final startDateStr = DateTimeUtils.formatDate(progress.startDateTime);
    final endDateStr = progress.endDateTime != null ? DateTimeUtils.formatDate(progress.endDateTime!) : "continue";
    final periodStr = _describeRepeatInfo(repeatInfo);
    return ListTile(
      leading: IconButton(
        icon: Icon(progress.isOngoing ? Icons.stop_circle_outlined : Icons.play_circle_outlined),
        onPressed: () {
          if (progress.isOngoing) {
            final newProgress = progress.stopped(DateTime.now());
            context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
            if (!_isCompletedSchedule(schedule, progress) && _isCompletedSchedule(schedule, newProgress)) {
              context.read<ScheduleBloc>().add(CompleteSchedule(schedule.id, DateTime.now()));
            }
          } else {
            final newProgress = progress.started(DateTime.now());
            context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
          }
        },
      ),
      title: Text("${schedule.title} (${_describeProgress(schedule.goal, progress)})"),
      subtitle: Text("$periodStr ($startDateStr ~ $endDateStr)"),
    );
  }

  String _describeRepeatInfo(RepeatInfo repeatInfo) {
    switch (repeatInfo) {
      case Unrepeated _:
        return "Unrepeated";
      case PeriodicRepeat p:
        return "Every ${p.periodDuration.toString()}";
      case UnknownRepeat _:
        return "Unknown Repeat";
    }
  }

  String _describeProgress(Goal goal, Progress progress) {
    if (goal is QuantityGoal && progress is QuantityProgress) {
      return "${progress.quantity}/${goal.quantity}";
    }
    if (goal is DurationGoal && progress is DurationProgress) {
      return "${progress.isOngoing ? "ongoing" : "stopped"} ${progress.duration}/${goal.duration}";
    }
    return "Invalid progress status";
  }
}
