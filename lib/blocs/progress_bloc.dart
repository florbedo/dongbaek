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

class UpdateQuantityProgress extends ProgressEvent {
  final ScheduleId scheduleId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dateTime;
  final int diff;

  UpdateQuantityProgress(this.scheduleId, this.startDate, this.endDate, this.dateTime, this.diff);
}

class UpdateDurationProgress extends ProgressEvent {
  final ScheduleId scheduleId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dateTime;
  final Duration diff;

  UpdateDurationProgress(this.scheduleId, this.startDate, this.endDate, this.dateTime, this.diff);
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

    on<UpdateQuantityProgress>((event, emit) async {
      await _handleUpdateQuantityProgress(event);
      add(RefreshProgresses(_scheduleIds, _dateTime));
    });
    on<UpdateDurationProgress>((event, emit) async {
      await _handleUpdateDurationProgress(event);
      add(RefreshProgresses(_scheduleIds, _dateTime));
    });

    add(RefreshProgresses(_scheduleIds, _dateTime));
  }

  Future<Map<ScheduleId, Progress>> _getProgresses(Iterable<ScheduleId> scheduleIds, DateTime dateTime) {
    return _progressRepository.getProgresses(scheduleIds, dateTime);
  }

  Future<void> _handleUpdateQuantityProgress(UpdateQuantityProgress e) async {
    final lastProgress = await _progressRepository.findProgress(e.scheduleId, e.dateTime);
    final lastQuantityProgress = lastProgress?.progressStatus as QuantityProgress?;
    final lastQuantity = lastQuantityProgress?.quantity ?? 0;
    final progressStatus = QuantityProgress(quantity: lastQuantity + e.diff);
    await _progressRepository.updateProgress(e.scheduleId, progressStatus, e.startDate, endDate: e.endDate);
  }

  Future<void> _handleUpdateDurationProgress(UpdateDurationProgress e) async {
    final lastProgress = await _progressRepository.findProgress(e.scheduleId, e.dateTime);
    final lastDurationProgress = lastProgress?.progressStatus as DurationProgress?;
    final lastDuration = lastDurationProgress?.duration ?? const Duration();
    final newDuration = Duration(seconds: lastDuration.inSeconds + e.diff.inSeconds);
    final progressStatus = DurationProgress(duration: newDuration);
    await _progressRepository.updateProgress(e.scheduleId, progressStatus, e.startDate, endDate: e.endDate);
  }
}
