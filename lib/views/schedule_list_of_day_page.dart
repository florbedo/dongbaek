import 'package:dongbaek/blocs/progress_bloc.dart';
import 'package:dongbaek/blocs/schedule_bloc.dart';
import 'package:dongbaek/blocs/snapshot_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/models/snapshot.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
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
          BlocProvider.of<ScheduleBloc>(context).add(const UpdateScheduleDate());
          BlocProvider.of<ProgressBloc>(context).add(const UpdateProgressDate());
          BlocProvider.of<SnapshotBloc>(context).add(const UpdateSnapshotDate());
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              "${_currentDate.year}/${_currentDate.month}/${_currentDate.day}(${DateTimeUtils.getDayOfWeek(_currentDate)})"),
        ),
        body: BlocBuilder<SnapshotBloc, List<Snapshot>>(builder: (context, List<Snapshot> snapshots) {
          final incompleteTiles = snapshots.where((s) => !s.isComplete()).map(_buildSnapshotTile).toList();
          final completeTiles = snapshots.where((s) => s.isComplete()).map(_buildSnapshotTile).toList();
          return ListView(
              children: List<Widget>.generate(
                    incompleteTiles.length,
                    (index) => Card(child: incompleteTiles[index]),
                  ) +
                  [
                    ExpandablePanel(
                      header: const ListTile(title: Text("Completed Schedules")),
                      collapsed: Container(),
                      expanded: Column(
                        children: List.generate(
                          completeTiles.length,
                          (int index) => Card(child: completeTiles[index]),
                        ),
                      ),
                    )
                  ] +
                  [Container(height: 80)]);
        }),
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

  Widget _buildSnapshotTile(Snapshot snapshot) {
    final schedule = snapshot.schedule;
    final progress = snapshot.progress;
    final repeatInfo = schedule.repeatInfo;
    Text subtitle;
    if (schedule.repeatInfo is RepeatPerDay) {
      subtitle = Text(
          '${progress.completeTimes.length} / ${(repeatInfo as RepeatPerDay).repeatCount} ${schedule.startDate}~ ${snapshot.isComplete()}');
    } else {
      subtitle = Text(
          '${progress.completeTimes.length} / ${(repeatInfo as RepeatPerWeek).repeatCount} ${schedule.startDate}~ ${snapshot.isComplete()}');
    }
    return ListTile(
      title: Text(schedule.title + " by " + (schedule.repeatInfo is RepeatPerDay ? "Daily" : "Weekly")),
      subtitle: subtitle,
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          context.read<ScheduleBloc>().add(RemoveSchedule(schedule.id!));
          context.read<SnapshotBloc>().add(const SnapshotDataUpdated());
        },
      ),
      onLongPress: () {
        context.read<ProgressBloc>().add(AddProgress(schedule.id!, DateTime.now()));
        context.read<SnapshotBloc>().add(const SnapshotDataUpdated());
      },
    );
  }
}
