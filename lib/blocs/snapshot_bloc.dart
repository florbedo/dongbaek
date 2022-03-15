import 'package:dongbaek/services/progress_service.dart';
import 'package:dongbaek/services/schedule_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/progress.dart';
import '../models/snapshot.dart';
import '../utils/datetime_utils.dart';

abstract class SnapshotEvent {
  const SnapshotEvent();
}

class UpdateSnapshotDate extends SnapshotEvent {
  const UpdateSnapshotDate();
}

class SnapshotDataUpdated extends SnapshotEvent {
  const SnapshotDataUpdated();
}

class SnapshotBloc extends Bloc<SnapshotEvent, List<Snapshot>> {
  final ScheduleService _scheduleService;
  final ProgressService _progressService;

  DateTime _currentDate = DateTimeUtils.truncateToDay(DateTime.now());

  SnapshotBloc(this._scheduleService, this._progressService) : super([]) {
    on<UpdateSnapshotDate>((event, emit) {
      _currentDate = DateTime.now();
      emit(_getSnapshots());
    });
    on<SnapshotDataUpdated>((event, emit) {
      emit(_getSnapshots());
    });
  }

  List<Snapshot> _getSnapshots() {
    final schedules = _scheduleService.getSchedules(_currentDate);
    final progressMap = _progressService.getProgressMap(_currentDate);
    return schedules.map((schedule) => Snapshot(schedule, progressMap[schedule.id] ?? Progress([]))).toList();
  }
}
