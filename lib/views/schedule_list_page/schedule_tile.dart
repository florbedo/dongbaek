import 'dart:developer' as dev;

import 'package:dongbaek/blocs/progress_bloc.dart';
import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleTile extends StatelessWidget {
  final Schedule _schedule;
  final Progress _progress;
  final bool completed;
  final GestureTapCallback? onTap;

  const ScheduleTile(this._schedule, this._progress, {Key? key, this.completed = false, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (_progress) {
      case QuantityProgress p:
        return _QuantityScheduleTile(_schedule, p, completed: completed, onTap: onTap);
      case DurationProgress p:
        return _DurationScheduleTile(_schedule, p, completed: completed, onTap: onTap);
    }
  }

  static Widget formatTitle(BuildContext context, String content, bool completed) {
    return Text(content,
        style: completed
            ? Theme.of(context).textTheme.titleMedium?.copyWith(decoration: TextDecoration.lineThrough)
            : Theme.of(context).textTheme.titleMedium);
  }
}

class _QuantityScheduleTile extends StatelessWidget {
  final Schedule _schedule;
  final QuantityProgress _progress;
  final bool completed;
  final GestureTapCallback? onTap;

  const _QuantityScheduleTile(this._schedule, this._progress, {Key? key, this.completed = false, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repeatInfo = _schedule.repeatInfo;
    final startDateStr = DateTimeUtils.formatDate(_progress.startDateTime);
    final endDateStr = _progress.endDateTime != null ? DateTimeUtils.formatDate(_progress.endDateTime!) : "continue";
    final periodStr = _describeRepeatInfo(repeatInfo);

    return ListTile(
      onTap: onTap,
      leading: IconButton(
        icon: const Icon(Icons.plus_one),
        onPressed: () {
          final newProgress = _progress.diff(1);
          context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
        },
      ),
      title: ScheduleTile.formatTitle(context, _describeProgress(_schedule, _progress), completed),
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

  String _describeProgress(Schedule schedule, QuantityProgress progress) {
    final goal = schedule.goal;
    if (goal is! QuantityGoal) {
      return "Invalid progress status";
    }
    return "${progress.quantity}/${goal.quantity}";
  }
}

class _DurationScheduleTile extends StatefulWidget {
  final Schedule _schedule;
  final DurationProgress _progress;
  final bool completed;
  final GestureTapCallback? onTap;

  const _DurationScheduleTile(this._schedule, this._progress, {this.completed = false, this.onTap, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DurationScheduleTileState();
}

class _DurationScheduleTileState extends State<_DurationScheduleTile> {
  @override
  Widget build(BuildContext context) {
    final schedule = widget._schedule;
    final progress = widget._progress;
    final completed = widget.completed;
    final onTap = widget.onTap;
    final repeatInfo = schedule.repeatInfo;
    final startDateStr = DateTimeUtils.formatDate(progress.startDateTime);
    final endDateStr = progress.endDateTime != null ? DateTimeUtils.formatDate(progress.endDateTime!) : "continue";
    final periodStr = _describeRepeatInfo(repeatInfo);

    return ListTile(
      onTap: onTap,
      leading: IconButton(
        icon: _getLeadingIcon(progress.isOngoing),
        onPressed: () {
          if (progress.isOngoing) {
            final newProgress = progress.stopped(DateTime.now());
            context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
          } else {
            final newProgress = progress.started(DateTime.now());
            context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
          }
        },
      ),
      title: ScheduleTile.formatTitle(context, _describeProgress(schedule, progress), completed),
      subtitle: Text("$periodStr ($startDateStr ~ $endDateStr)"),
    );
  }

  Widget _getLeadingIcon(bool isOngoing) {
    if (isOngoing) {
      return const Icon(Icons.stop_circle_outlined);
    }
    return const Icon(Icons.play_circle_outlined);
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

  String _describeProgress(Schedule schedule, DurationProgress progress) {
    final goal = schedule.goal;
    if (goal is! DurationGoal) {
      return "Invalid progress status";
    }
    return "${schedule.title} (${progress.isOngoing ? "ongoing" : "stopped"} ${progress.duration}/${goal.duration})";
  }
}
