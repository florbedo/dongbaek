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
    final repeatInfo = _schedule.repeatInfo;
    final startDateStr = DateTimeUtils.formatDate(_progress.startDateTime);
    final endDateStr = _progress.endDateTime != null ? DateTimeUtils.formatDate(_progress.endDateTime!) : "continue";
    final periodStr = _describeRepeatInfo(repeatInfo);

    return ListTile(
      onTap: onTap,
      leading: IconButton(
        icon: _getProgressLeadingIcon(),
        onPressed: () {
          switch (_progress) {
            case QuantityProgress p:
              final newProgress = p.diff(1);
              context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
            case DurationProgress p:
              if (p.isOngoing) {
                final newProgress = p.stopped(DateTime.now());
                context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
              } else {
                final newProgress = p.started(DateTime.now());
                context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
              }
          }
        },
      ),
      title: Text("${_schedule.title} (${_describeProgress(_schedule.goal, _progress)})",
          style: completed
              ? Theme.of(context).textTheme.titleMedium?.copyWith(decoration: TextDecoration.lineThrough)
              : Theme.of(context).textTheme.titleMedium),
      subtitle: Text("$periodStr ($startDateStr ~ $endDateStr)"),
    );
  }

  Widget _getProgressLeadingIcon() {
    switch (_progress) {
      case QuantityProgress _:
        return const Icon(Icons.plus_one);
      case DurationProgress p:
        if (p.isOngoing) {
          return const Icon(Icons.stop_circle_outlined);
        }
        return const Icon(Icons.play_circle_outlined);
    }
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
