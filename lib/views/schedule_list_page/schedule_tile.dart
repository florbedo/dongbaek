import 'dart:developer' as dev;

import 'package:dongbaek/blocs/progress_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
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
        final ongoingStartTime = p.ongoingStartTime;
        if (ongoingStartTime == null) {
          return _StoppedDurationScheduleTile(_schedule, p, completed: completed, onTap: onTap);
        }
        return _OngoingDurationScheduleTile(_schedule, p, ongoingStartTime, completed: completed, onTap: onTap);
    }
  }

  static Widget formatTitle(BuildContext context, String content, bool completed) {
    return Text(content,
        style: completed
            ? Theme.of(context).textTheme.titleMedium?.copyWith(decoration: TextDecoration.lineThrough)
            : Theme.of(context).textTheme.titleMedium);
  }

  static String describeRepeatInfo(RepeatInfo repeatInfo) {
    switch (repeatInfo) {
      case Unrepeated _:
        return "Unrepeated";
      case PeriodicRepeat p:
        return "Every ${p.periodDuration.toString()}";
      case UnknownRepeat _:
        return "Unknown Repeat";
    }
  }

  static String formatDuration(Duration duration) {
    String hourDesc = "";
    if (duration.inHours > 0) {
      hourDesc = "${duration.inHours}시간";
    }
    String minDesc = "";
    if (duration.inMinutes % 60 > 0) {
      minDesc = "${duration.inMinutes % 60}분";
    }
    String secDesc = "";
    if ((hourDesc.isEmpty && minDesc.isEmpty) || duration.inSeconds % 60 > 0) {
      secDesc = "${duration.inSeconds % 60}초";
    }
    return [hourDesc, minDesc, secDesc].where((s) => s.isNotEmpty).join(" ");
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
    final periodStr = ScheduleTile.describeRepeatInfo(repeatInfo);

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

  String _describeProgress(Schedule schedule, QuantityProgress progress) {
    final goal = schedule.goal;
    if (goal is! QuantityGoal) {
      return "Invalid progress status";
    }
    return "${progress.quantity}/${goal.quantity}";
  }
}

class _StoppedDurationScheduleTile extends StatelessWidget {
  final Schedule _schedule;
  final DurationProgress _progress;
  final bool completed;
  final GestureTapCallback? onTap;

  const _StoppedDurationScheduleTile(this._schedule, this._progress, {Key? key, this.completed = false, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repeatInfo = _schedule.repeatInfo;
    final startDateStr = DateTimeUtils.formatDate(_progress.startDateTime);
    final endDateStr = _progress.endDateTime != null ? DateTimeUtils.formatDate(_progress.endDateTime!) : "continue";
    final periodStr = ScheduleTile.describeRepeatInfo(repeatInfo);

    return ListTile(
      onTap: onTap,
      leading: IconButton(
        icon: const Icon(Icons.play_circle_outlined),
        onPressed: () {
          final newProgress = _progress.started(DateTime.now());
          context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
        },
      ),
      title: ScheduleTile.formatTitle(context, _describeProgress(_schedule, _progress), completed),
      subtitle: Text("$periodStr ($startDateStr ~ $endDateStr)"),
    );
  }

  String _describeProgress(Schedule schedule, DurationProgress progress) {
    final goal = schedule.goal;
    if (goal is! DurationGoal) {
      return "Invalid progress status";
    }
    return "${schedule.title} (stopped ${ScheduleTile.formatDuration(progress.duration)} / ${ScheduleTile.formatDuration(goal.duration)})";
  }
}

class _OngoingDurationScheduleTile extends StatefulWidget {
  final Schedule _schedule;
  final DurationProgress _progress;
  final DateTime _ongoingStartTime;
  final bool completed;
  final GestureTapCallback? onTap;

  const _OngoingDurationScheduleTile(this._schedule, this._progress, this._ongoingStartTime,
      {this.completed = false, this.onTap, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _OngoingDurationScheduleTileState();
}

class _OngoingDurationScheduleTileState extends State<_OngoingDurationScheduleTile> {
  DateTime ongoingCurrentDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final schedule = widget._schedule;
    final progress = widget._progress;
    final completed = widget.completed;
    final onTap = widget.onTap;
    final repeatInfo = schedule.repeatInfo;
    final startDateStr = DateTimeUtils.formatDate(progress.startDateTime);
    final endDateStr = progress.endDateTime != null ? DateTimeUtils.formatDate(progress.endDateTime!) : "continue";
    final periodStr = ScheduleTile.describeRepeatInfo(repeatInfo);

    return BlocListener<TimerBloc, DateTime>(
      listenWhen: (before, current) {
        final sumDurationBefore = progress.duration + before.difference(widget._ongoingStartTime);
        final sumDurationCurrent = progress.duration + current.difference(widget._ongoingStartTime);
        return sumDurationBefore.inSeconds != sumDurationCurrent.inSeconds;
      },
      listener: (context, DateTime dateTime) {
        setState(() {
          ongoingCurrentDateTime = dateTime;
        });
      },
      child: ListTile(
        onTap: onTap,
        leading: IconButton(
          icon: const Icon(Icons.stop_circle_outlined),
          onPressed: () {
            final newProgress = progress.stopped(DateTime.now());
            context.read<ProgressBloc>().add(ReplaceProgress(newProgress));
          },
        ),
        title: ScheduleTile.formatTitle(context, _describeProgress(schedule, progress), completed),
        subtitle: Text("$periodStr ($startDateStr ~ $endDateStr)"),
      ),
    );
  }

  String _describeProgress(Schedule schedule, DurationProgress progress) {
    final goal = schedule.goal;
    if (goal is! DurationGoal) {
      return "Invalid progress status";
    }
    final ongoingDuration = ongoingCurrentDateTime.difference(widget._ongoingStartTime);
    final sumDuration = progress.duration + ongoingDuration;
    return "${schedule.title} (ongoing ${ScheduleTile.formatDuration(sumDuration)} / ${ScheduleTile.formatDuration(goal.duration)})";
  }
}
