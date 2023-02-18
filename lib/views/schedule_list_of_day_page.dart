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
                  .filter((pair) => !_isCompletedScheduleProgress(pair.first, pair.second))
                  .map((pair) => _buildScheduleProgressTile(pair.first, pair.second))
                  .toList();
              final completedTiles = scheduleAndProgressPairs
                  .filter((pair) => _isCompletedScheduleProgress(pair.first, pair.second))
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

  bool _isCompletedScheduleProgress(Schedule schedule, Progress progress) {
    final goal = schedule.goal;
    if (goal is QuantityGoal && progress is QuantityProgress) {
      return goal.quantity <= progress.quantity;
    }
    if (goal is DurationGoal && progress is DurationProgress) {
      if (progress.isOngoing) {
        return false;
      }
      return goal.duration.inSeconds <= progress.duration.inSeconds;
    }
    throw UnimplementedError("INVALID_SCHEDULE_AND_PROGRESS $schedule $progress");
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
    final startDateStr = DateTimeUtils.formatDate(progress.startDate);
    final endDateStr = progress.endDate != null ? DateTimeUtils.formatDate(progress.endDate!) : "continue";
    final periodStr = repeatInfo is Unrepeated
        ? "Unrepeated"
        : (repeatInfo as PeriodicRepeat).periodDays > 1
            ? "Every ${repeatInfo.periodDays} days"
            : "Every day";
    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.plus_one),
        onPressed: () {
          final newProgress = progress.diff(1);
          context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
          if (!_isCompletedScheduleProgress(schedule, progress) &&
              _isCompletedScheduleProgress(schedule, newProgress)) {
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
    final startDateStr = DateTimeUtils.formatDate(progress.startDate);
    final endDateStr = progress.endDate != null ? DateTimeUtils.formatDate(progress.endDate!) : "continue";
    final periodStr = repeatInfo is Unrepeated
        ? "Unrepeated"
        : (repeatInfo as PeriodicRepeat).periodDays > 1
            ? "Every ${repeatInfo.periodDays} days"
            : "Every day";
    return ListTile(
      leading: IconButton(
        icon: Icon(progress.isOngoing ? Icons.stop_circle_outlined : Icons.play_circle_outlined),
        onPressed: () {
          if (progress.isOngoing) {
            final newProgress = progress.stopped(DateTime.now());
            context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
            if (!_isCompletedScheduleProgress(schedule, progress) &&
                _isCompletedScheduleProgress(schedule, newProgress)) {
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
