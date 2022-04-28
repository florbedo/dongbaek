import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/models/snapshot.dart';
import 'package:dongbaek/repositories/progress_repository.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SnapshotEvent {
  const SnapshotEvent();
}

class UpdateSnapshotDate extends SnapshotEvent {
  const UpdateSnapshotDate();
}

class SnapshotDataUpdated extends SnapshotEvent {
  const SnapshotDataUpdated();
}


abstract class ScheduleEvent extends SnapshotEvent {}

class AddSchedule extends ScheduleEvent {
  final String title;
  final DateTime startDate;
  final RepeatInfo repeatInfo;

  AddSchedule(this.title, this.startDate, this.repeatInfo);
}

class RemoveSchedule extends ScheduleEvent {
  final int targetId;

  RemoveSchedule(this.targetId);
}


abstract class ProgressEvent extends SnapshotEvent {}

class UpdateQuantityProgress extends ProgressEvent {
  final int scheduleId;
  final DateTime dateTime;
  final int diff;

  UpdateQuantityProgress(this.scheduleId, this.dateTime, this.diff);
}

class UpdateDurationProgress extends ProgressEvent {
  final int scheduleId;
  final DateTime dateTime;
  final Duration diff;

  UpdateDurationProgress(this.scheduleId, this.dateTime, this.diff);
}

class SnapshotBloc extends Bloc<SnapshotEvent, List<Snapshot>> {
  final ScheduleRepository _scheduleRepository;
  final ProgressRepository _progressRepository;

  DateTime _currentDate = DateTimeUtils.truncateToDay(DateTime.now());

  SnapshotBloc(this._scheduleRepository, this._progressRepository) : super([]) {
    on<UpdateSnapshotDate>((event, emit) async {
      _currentDate = DateTimeUtils.truncateToDay(DateTime.now());
      final snapshots = await _getSnapshots();
      emit(snapshots);
    });
    on<SnapshotDataUpdated>((event, emit) async {
      final snapshots = await _getSnapshots();
      emit(snapshots);
    });

    on<AddSchedule>((event, emit) async {
      await _handleAddSchedule(event);
      add(const SnapshotDataUpdated());
    });
    on<RemoveSchedule>((event, emit) async {
      await _handleRemoveSchedule(event);
      add(const SnapshotDataUpdated());
    });

    on<UpdateQuantityProgress>((event, emit) async {
      _handleUpdateQuantityProgress(event);
      add(const SnapshotDataUpdated());
    });
    on<UpdateDurationProgress>((event, emit) async {
      _handleUpdateDurationProgress(event);
      add(const SnapshotDataUpdated());
    });

    add(const UpdateSnapshotDate());
  }

  Future<List<Snapshot>> _getSnapshots() async {
    final schedules = await _scheduleRepository.getSchedules(_currentDate);
    final progressMap = await _progressRepository.getProgressMap(_currentDate);
    return schedules.map((schedule) {
      final progress = progressMap[schedule.id] ?? Progress.getDefault(schedule.repeatInfo);
      return Snapshot(schedule, progress);
    }).toList();
  }


  Future<void> _handleAddSchedule(AddSchedule e) async {
    Schedule newSchedule = Schedule(null, e.title, e.repeatInfo, e.startDate);
    await _scheduleRepository.addSchedule(newSchedule);
  }

  Future<void> _handleRemoveSchedule(RemoveSchedule e) async {
    await _scheduleRepository.removeSchedule(e.targetId);
  }


  void _handleUpdateQuantityProgress(UpdateQuantityProgress e) {
    _progressRepository.updateQuantityProgress(e.scheduleId, e.dateTime, e.diff);
  }

  void _handleUpdateDurationProgress(UpdateDurationProgress e) {
    _progressRepository.updateDurationProgress(e.scheduleId, e.dateTime, e.diff);
  }
}
