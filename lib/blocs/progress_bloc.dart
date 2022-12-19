import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/repositories/progress_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProgressEvent {
  const ProgressEvent();
}

class RefreshProgresses extends ProgressEvent {
  final List<ScheduleId> scheduleIds;
  final DateTime dateTime;

  RefreshProgresses(this.scheduleIds, this.dateTime);
}

class ReplaceProgress extends ProgressEvent {
  final Progress progress;

  ReplaceProgress(this.progress);
}

class ProgressBloc extends Bloc<ProgressEvent, Map<ScheduleId, Progress>> {
  final ProgressRepository _progressRepository;

  List<ScheduleId> _scheduleIds = [];
  DateTime _dateTime = DateTime.now();

  ProgressBloc(this._progressRepository) : super({}) {
    on<RefreshProgresses>((event, emit) async {
      _scheduleIds = event.scheduleIds;
      _dateTime = event.dateTime;
      final snapshots = await _getProgresses(_scheduleIds, _dateTime);
      emit(snapshots);
    });

    on<ReplaceProgress>((event, emit) async {
      await _handleReplaceProgress(event);
      add(RefreshProgresses(_scheduleIds, _dateTime));
    });

    add(RefreshProgresses(_scheduleIds, _dateTime));
  }

  Future<Map<ScheduleId, Progress>> _getProgresses(Iterable<ScheduleId> scheduleIds, DateTime dateTime) {
    return _progressRepository.getProgresses(scheduleIds, dateTime);
  }

  Future<void> _handleReplaceProgress(ReplaceProgress e) async {
    await _progressRepository.replaceProgress(e.progress);
  }
}
