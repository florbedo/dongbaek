import 'package:dongbaek/models/progress.dart';
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

class SnapshotBloc extends Bloc<SnapshotEvent, List<Snapshot>> {
  final ScheduleRepository _scheduleRepository;
  final ProgressRepository _progressRepository;

  DateTime _currentDate = DateTimeUtils.truncateToDay(DateTime.now());

  SnapshotBloc(this._scheduleRepository, this._progressRepository) : super([]) {
    on<UpdateSnapshotDate>((event, emit) async {
      _currentDate = DateTime.now();
      final snapshots = await _getSnapshots();
      emit(snapshots);
    });
    on<SnapshotDataUpdated>((event, emit) async {
      final snapshots = await _getSnapshots();
      emit(snapshots);
    });
  }

  Future<List<Snapshot>> _getSnapshots() async {
    final schedules = await _scheduleRepository.getSchedules(_currentDate);
    final progressMap = _progressRepository.getProgressMap(_currentDate);
    return schedules.map((schedule) => Snapshot(schedule, progressMap[schedule.id] ?? Progress([]))).toList();
  }
}
