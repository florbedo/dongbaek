import 'package:dongbaek/blocs/snapshot_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
import 'package:dongbaek/models/snapshot.dart';
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
          BlocProvider.of<SnapshotBloc>(context).add(const UpdateSnapshotDate());
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              "${_currentDate.year}/${_currentDate.month}/${_currentDate.day}(${DateTimeUtils.getDayOfWeek(_currentDate)})"),
        ),
        body: BlocBuilder<SnapshotBloc, List<Snapshot>>(builder: (context, List<Snapshot> snapshots) {
          final tiles = snapshots.map(_buildSnapshotTile).toList();
          return ListView(
              children: List<Widget>.generate(
                    tiles.length,
                    (index) => Card(child: tiles[index]),
                  ) +
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
    subtitle = Text('${repeatInfo.runtimeType} / ${repeatInfo.startDate} ${repeatInfo.ended} ${progress.runtimeType}');
    return ListTile(
      title: Text(schedule.title),
      subtitle: subtitle,
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          context.read<SnapshotBloc>().add(RemoveSchedule(schedule.id!));
          context.read<SnapshotBloc>().add(const SnapshotDataUpdated());
        },
      ),
      onLongPress: () {
        // context.read<ProgressBloc>().add(UpdateQuantityProgress(schedule.id!, DateTime.now()));
        context.read<SnapshotBloc>().add(const SnapshotDataUpdated());
      },
    );
  }
}
