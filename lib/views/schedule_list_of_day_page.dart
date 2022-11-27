import 'package:dongbaek/blocs/progress_bloc.dart';
import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
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
            return BlocBuilder<ProgressBloc, Map<ScheduleId, Progress>>(
                builder: (context, Map<ScheduleId, Progress> progressMap) {
              final tiles = schedules.map((schedule) {
                final progress = progressMap[schedule.id] ?? Progress.getDefaultProgress(schedule);
                return _buildSnapshotTile(schedule, progress);
              }).toList();
              return ListView(
                  children: List<Widget>.generate(
                        tiles.length,
                        (index) => Card(child: tiles[index]),
                      ) +
                      [Container(height: 80)]);
            });
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.pushNamed(context, "/addSchedule");
          },
          tooltip: 'Add',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSnapshotTile(Schedule schedule, Progress progress) {
    final repeatInfo = schedule.repeatInfo;
    Text subtitle;
    subtitle = Text('${repeatInfo.runtimeType} / ${schedule.startDate} ${schedule.dueDate} ${progress.runtimeType}');
    return ListTile(
      title: Text(schedule.title),
      subtitle: subtitle,
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          context.read<ScheduleBloc>().add(RemoveSchedule(schedule.id));
          context.read<ScheduleBloc>().add(RefreshSchedules());
        },
      ),
      onLongPress: () {
        // context.read<ProgressBloc>().add(UpdateQuantityProgress(schedule.id!, DateTime.now()));
        context.read<ScheduleBloc>().add(RefreshSchedules());
      },
    );
  }
}
