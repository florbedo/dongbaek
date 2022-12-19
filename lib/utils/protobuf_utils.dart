import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/proto/google/protobuf/duration.pb.dart' as pb_ds;
import 'package:dongbaek/proto/google/protobuf/timestamp.pb.dart' as pb_ts;
import 'package:dongbaek/proto/messages.pb.dart';
import 'package:fixnum/fixnum.dart';

class ProtobufUtils {
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
    final startDate = ProtobufUtils.asPbTimestamp(schedule.startDate);
    final dueDate = (schedule.dueDate != null) ? ProtobufUtils.asPbTimestamp(schedule.dueDate!) : null;
    final finishDate = (schedule.finishDate != null) ? ProtobufUtils.asPbTimestamp(schedule.finishDate!) : null;
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
      return PbGoal(durationGoal: ProtobufUtils.asPbDuration(goal.duration));
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
    return Progress(ProgressId(id), ScheduleId(scheduleId), startDate.toDateTime(), endDateVal, getProgressStatus());
  }

  ProgressStatus getProgressStatus() {
    switch (whichProgressStatus()) {
      case PbProgress_ProgressStatus.quantityProgress:
        return QuantityProgress(quantity: quantityProgress);
      case PbProgress_ProgressStatus.durationProgress:
        final microseconds = durationProgress.nanos ~/ 1000;
        return DurationProgress(duration: Duration(microseconds: microseconds));
      default:
        return const UnknownProgressStatus();
    }
  }

  static int? asQuantityProgress(ProgressStatus ps) {
    if (ps is QuantityProgress) {
      return ps.quantity;
    }
    return null;
  }

  static pb_ds.Duration? asDurationProgress(ProgressStatus ps) {
    if (ps is DurationProgress) {
      final seconds = ps.duration.inSeconds;
      final secondsInt64 = Int64(seconds);
      return pb_ds.Duration(seconds: secondsInt64);
    }
    return null;
  }
}
