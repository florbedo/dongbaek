import 'dart:developer' as dev;

import 'package:dongbaek/blocs/progress_bloc.dart';
import 'package:dongbaek/blocs/timer_bloc.dart';
import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:dongbaek/utils/duration_utils.dart';
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
        return "반복 없음";
      case PeriodicRepeat p:
        return "매 ${p.periodDuration.text}동안";
      case UnknownRepeat _:
        return "Unknown Repeat";
    }
  }

  static String describeDuePeriod(DateTime startDateTime, DateTime? endDateTime) {
    if (endDateTime == null) {
      return "기한 없음";
    }
    final startDateStr = DateTimeUtils.formatDate(startDateTime);
    final endDateStr = DateTimeUtils.formatDate(endDateTime.subtract(const Duration(seconds: 1)));
    if (startDateTime.compareTo(endDateTime) == 0) {
      return startDateStr;
    }
    return "$startDateStr부터 ~ $endDateStr이전까지";
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
      subtitle: Text("${ScheduleTile.describeRepeatInfo(repeatInfo)} (${ScheduleTile.describeDuePeriod(_progress.startDateTime, _progress.endDateTime)})"),
    );
  }

  String _describeProgress(Schedule schedule, QuantityProgress progress) {
    final goal = schedule.goal;
    if (goal is! QuantityGoal) {
      return "Invalid progress status";
    }
    return "${schedule.title} (${progress.quantity}/${goal.quantity})";
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
      subtitle: Text("${ScheduleTile.describeRepeatInfo(repeatInfo)} (${ScheduleTile.describeDuePeriod(_progress.startDateTime, _progress.endDateTime)})"),
    );
  }

  String _describeProgress(Schedule schedule, DurationProgress progress) {
    final goal = schedule.goal;
    if (goal is! DurationGoal) {
      return "Invalid progress status";
    }
    return "${schedule.title} (stopped ${progress.duration.text} / ${goal.duration.text})";
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
        subtitle: Text("${ScheduleTile.describeRepeatInfo(repeatInfo)} (${ScheduleTile.describeDuePeriod(progress.startDateTime, progress.endDateTime)})"),
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
    return "${schedule.title} (ongoing ${sumDuration.text} / ${goal.duration.text})";
  }
}
