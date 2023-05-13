import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/proto/google/protobuf/duration.pb.dart' as pb_ds;
import 'package:dongbaek/proto/google/protobuf/timestamp.pb.dart' as pb_ts;
import 'package:dongbaek/proto/models.pb.dart';
import 'package:fixnum/fixnum.dart';

class PbUtils {
  static asPbTimestamp(DateTime dateTime) {
    return pb_ts.Timestamp(seconds: Int64(dateTime.millisecondsSinceEpoch ~/ 1000));
  }

  static asPbDuration(Duration duration) {
    final epochSec = duration.inSeconds;
    return pb_ds.Duration(seconds: Int64(epochSec));
  }
}

extension PbScheduleExt on PbSchedule {
  static PbSchedule fromSchedule(Schedule schedule) {
    final startDate = PbUtils.asPbTimestamp(schedule.startDate);
    final dueDate = (schedule.dueDate != null) ? PbUtils.asPbTimestamp(schedule.dueDate!) : null;
    final finishDate = (schedule.finishDate != null) ? PbUtils.asPbTimestamp(schedule.finishDate!) : null;
    return PbSchedule(
      id: schedule.id.value,
      title: schedule.title,
      startDate: startDate,
      dueDate: dueDate,
      finishDate: finishDate,
      goal: PbGoalExt.asPbGoal(schedule.goal),
      repeatInfo: PbRepeatInfoExt.asPbRepeatInfo(schedule.repeatInfo),
    );
  }

  Schedule toSchedule() {
    return Schedule(ScheduleId(id), title, getGoal(), getRepeatInfo(), startDate.toDateTime(),
        dueDate: hasDueDate() ? dueDate.toDateTime() : null,
        finishDate: hasFinishDate() ? finishDate.toDateTime() : null);
  }

  Goal getGoal() {
    switch (goal.whichValue()) {
      case PbGoal_Value.quantityGoal:
        return QuantityGoal(goal.quantityGoal);
      case PbGoal_Value.durationGoal:
        return DurationGoal(Duration(seconds: goal.durationGoal.seconds.toInt()));
      default:
        return const UnknownGoal();
    }
  }

  RepeatInfo getRepeatInfo() {
    switch (repeatInfo.whichValue()) {
      case PbRepeatInfo_Value.unrepeated:
        return const Unrepeated();
      case PbRepeatInfo_Value.periodicRepeat:
        return PeriodicRepeat(repeatInfo.periodicRepeat.periodDays, repeatInfo.periodicRepeat.offsetDays);
      default:
        return const UnknownRepeat();
    }
  }
}

extension PbGoalExt on PbGoal {
  static PbGoal? asPbGoal(Goal goal) {
    if (goal is QuantityGoal) {
      return PbGoal(quantityGoal: goal.quantity);
    } else if (goal is DurationGoal) {
      return PbGoal(durationGoal: PbUtils.asPbDuration(goal.duration));
    }
    return null;
  }
}

extension PbRepeatInfoExt on PbRepeatInfo {
  static PbRepeatInfo? asPbRepeatInfo(RepeatInfo repeatInfo) {
    if (repeatInfo is Unrepeated) {
      return PbRepeatInfo(unrepeated: PbUnrepeated());
    } else if (repeatInfo is PeriodicRepeat) {
      final pbPeriodic = PbPeriodic(periodDays: repeatInfo.periodDays, offsetDays: repeatInfo.offsetDays);
      return PbRepeatInfo(periodicRepeat: pbPeriodic);
    }
    return null;
  }
}

extension PbProgressExt on PbProgress {
  Progress getProgress() {
    final endDateVal = hasEndDate() ? endDate.toDateTime() : null;
    switch (whichProgressStatus()) {
      case PbProgress_ProgressStatus.quantityProgress:
        return QuantityProgress(ProgressId(id), ScheduleId(scheduleId), startDate.toDateTime(), endDateVal,
            quantity: quantityProgress.value);
      case PbProgress_ProgressStatus.durationProgress:
        final microseconds =
            (durationProgress.value.seconds.toInt() * 1000 * 1000) + (durationProgress.value.nanos ~/ 1000);
        return DurationProgress(
          ProgressId(id),
          ScheduleId(scheduleId),
          startDate.toDateTime(),
          endDateVal,
          duration: Duration(microseconds: microseconds),
          ongoingStartTime:
              durationProgress.hasOngoingStartTime() ? durationProgress.ongoingStartTime.toDateTime() : null,
        );
      default:
        throw UnimplementedError("Invalid progress status");
    }
  }

  static PbQuantityProgress? getPbQuantityProgress(Progress progress) {
    if (progress is QuantityProgress) {
      return PbQuantityProgress(value: progress.quantity);
    }
    return null;
  }

  static PbDurationProgress? getPbDurationProgress(Progress progress) {
    if (progress is DurationProgress) {
      final seconds = progress.duration.inSeconds;
      final secondsInt64 = Int64(seconds);
      return PbDurationProgress(
          value: pb_ds.Duration(seconds: secondsInt64),
          ongoingStartTime: progress.isOngoing ? PbUtils.asPbTimestamp(progress.ongoingStartTime!) : null);
    }
    return null;
  }
}
