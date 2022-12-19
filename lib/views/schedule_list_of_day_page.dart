import 'package:dongbaek/blocs/progress_bloc.dart';
import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:dongbaek/views/components/add_schedule_card.dart';
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
              final tiles = schedules.map((schedule) {
                // Fill default progress in repository
                final progress = progressMap[schedule.id]!;
                return _buildScheduleProgressTile(schedule, progress);
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

  Widget _buildScheduleProgressTile(Schedule schedule, Progress progress) {
    if (schedule.repeatInfo is Unrepeated) {
      return _buildUnrepeatedScheduleTile(schedule, progress);
    }
    if (schedule.repeatInfo is PeriodicRepeat) {
      return _buildPeriodicScheduleTile(schedule, progress);
    }
    throw UnimplementedError();
  }

  Widget _buildUnrepeatedScheduleTile(Schedule schedule, Progress progress) {
    final goal = schedule.goal;
    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.plus_one),
        onPressed: () {
          if (goal is QuantityGoal) {
            final newProgress = progress.diffQuantityProgress(1);
            context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
          }
        },
      ),
      title: Text("${schedule.title} (${_describeProgress(goal, progress)})"),
      subtitle: Text(
          "${DateTimeUtils.formatDateTime(progress.startDate)} ~ ${progress.endDate != null ? DateTimeUtils.formatDateTime(progress.endDate!) : ""}"),
    );
  }

  Widget _buildPeriodicScheduleTile(Schedule schedule, Progress progress) {
    final repeatInfo = schedule.repeatInfo as PeriodicRepeat;
    final goal = schedule.goal;
    final startDateStr = DateTimeUtils.formatDateTime(progress.startDate);
    final endDateStr = progress.endDate != null ? DateTimeUtils.formatDateTime(progress.endDate!) : "INVALID_END_DATE";
    final periodStr = repeatInfo.periodDays > 1 ? "Every ${repeatInfo.periodDays} days" : "Every day";
    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.plus_one),
        onPressed: () {
          if (goal is QuantityGoal) {
            final newProgress = progress.diffQuantityProgress(1);
            context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
          }
        },
      ),
      title: Text("${schedule.title} (${_describeProgress(goal, progress)})"),
      subtitle: Text("$periodStr ($startDateStr ~ $endDateStr)"),
    );
  }

  String _describeProgress(Goal goal, Progress progress) {
    if (goal is QuantityGoal) {
      return "${(progress.progressStatus as QuantityProgress).quantity}/${goal.quantity}";
    }
    if (goal is DurationGoal) {
      return "${(progress.progressStatus as DurationProgress).duration}/${goal.duration}";
    }
    return "Invalid progress status";
  }
}
