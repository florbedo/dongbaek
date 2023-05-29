import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/proto/google/protobuf/duration.pb.dart' as pb_dr;
import 'package:dongbaek/proto/google/protobuf/timestamp.pb.dart' as pb_ts;
import 'package:dongbaek/proto/models.pb.dart';
import 'package:fixnum/fixnum.dart';

extension DateTimeExt on DateTime {
  toPbTimestamp() {
    final seconds = microsecondsSinceEpoch ~/ 1000000;
    final nanos = (microsecondsSinceEpoch % 1000000) * 1000;
    return pb_ts.Timestamp(seconds: Int64(seconds), nanos: nanos);
  }
}

extension PbDurationExt on pb_dr.Duration {
  toDuration() {
    return Duration(seconds: seconds.toInt(), microseconds: nanos ~/ 1000);
  }
}

extension DurationExt on Duration {
  toPbDuration() {
    final seconds = inMicroseconds ~/ 1000000;
    final nanos = (inMicroseconds % 1000000) * 1000;
    return pb_dr.Duration(seconds: Int64(seconds), nanos: nanos);
  }
}

extension PbScheduleExt on PbSchedule {
  Schedule toSchedule() {
    return Schedule(ScheduleId(id), title, goal.toGoal(), repeatInfo.toRepeatInfo(), startTimestamp.toDateTime(),
        dueDateTime: hasDueTimestamp() ? dueTimestamp.toDateTime() : null,
        finishDateTime: hasFinishTimestamp() ? finishTimestamp.toDateTime() : null);
  }
}

extension ScheduleExt on Schedule {
  PbSchedule toPbSchedule() {
    return PbSchedule(
      id: id.value,
      title: title,
      startTimestamp: startDateTime.toPbTimestamp(),
      dueTimestamp: dueDateTime?.toPbTimestamp(),
      finishTimestamp: finishDateTime?.toPbTimestamp(),
      goal: goal.toPbGoal(),
      repeatInfo: repeatInfo.toPbRepeatInfo(),
    );
  }
}

extension PbGoalExt on PbGoal {
  Goal toGoal() {
    switch (whichValue()) {
      case PbGoal_Value.quantityGoal:
        return QuantityGoal(quantityGoal);
      case PbGoal_Value.durationGoal:
        return DurationGoal(durationGoal.toDuration());
      default:
        return const UnknownGoal();
    }
  }
}

extension GoalExt on Goal {
  PbGoal toPbGoal() {
    switch (this) {
      case QuantityGoal g:
        return PbGoal(quantityGoal: g.quantity);
      case DurationGoal g:
        return PbGoal(durationGoal: g.duration.toPbDuration());
      case UnknownGoal _:
        throw UnimplementedError();
    }
  }
}

extension PbRepeatInfoExt on PbRepeatInfo {
  RepeatInfo toRepeatInfo() {
    switch (whichValue()) {
      case PbRepeatInfo_Value.unrepeated:
        return const Unrepeated();
      case PbRepeatInfo_Value.periodicRepeat:
        return PeriodicRepeat(periodicRepeat.periodDays, periodicRepeat.offsetDays);
      default:
        return const UnknownRepeat();
    }
  }
}

extension RepeatInfoExt on RepeatInfo {
  PbRepeatInfo? toPbRepeatInfo() {
    switch (this) {
      case Unrepeated _:
        return PbRepeatInfo(unrepeated: PbUnrepeated());
      case PeriodicRepeat p:
        final pbPeriodic = PbPeriodic(periodDays: p.periodDays, offsetDays: p.offsetDays);
        return PbRepeatInfo(periodicRepeat: pbPeriodic);
      case UnknownRepeat _:
        return null;
    }
  }
}

extension PbProgressExt on PbProgress {
  Progress toProgress() {
    final endDateVal = hasEndTimestamp() ? endTimestamp.toDateTime() : null;
    switch (whichProgressStatus()) {
      case PbProgress_ProgressStatus.quantityProgress:
        return QuantityProgress(ScheduleId(scheduleId), startTimestamp.toDateTime(), endDateVal,
            quantity: quantityProgress.quantity);
      case PbProgress_ProgressStatus.durationProgress:
        return DurationProgress(
          ScheduleId(scheduleId),
          startTimestamp.toDateTime(),
          endDateVal,
          duration: durationProgress.duration.toDuration(),
          ongoingStartTime:
              durationProgress.hasOngoingStartTimestamp() ? durationProgress.ongoingStartTimestamp.toDateTime() : null,
        );
      default:
        throw UnimplementedError("Invalid progress status");
    }
  }
}

extension ProgressExt on Progress {
  PbProgress toPbProgress() {
    final pbQuantityProgress = getPbQuantityProgress();
    final pbDurationProgress = getPbDurationProgress();
    return PbProgress(
      scheduleId: scheduleId.value,
      startTimestamp: startDateTime.toPbTimestamp(),
      endTimestamp: endDateTime?.toPbTimestamp(),
      quantityProgress: pbQuantityProgress,
      durationProgress: pbDurationProgress,
    );
  }

  PbQuantityProgress? getPbQuantityProgress() {
    switch (this) {
      case QuantityProgress p:
        return PbQuantityProgress(quantity: p.quantity);
      case DurationProgress _:
        return null;
    }
  }

  PbDurationProgress? getPbDurationProgress() {
    switch (this) {
      case QuantityProgress _:
        return null;
      case DurationProgress p:
        return PbDurationProgress(
            duration: p.duration.toPbDuration(), ongoingStartTimestamp: p.ongoingStartTime?.toPbTimestamp());
    }
  }
}
