import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/repositories/progress_repository.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProgressEvent {
  const ProgressEvent();
}

class UpdateProgressDate extends ProgressEvent {
  const UpdateProgressDate();
}

class AddProgress extends ProgressEvent {
  final int scheduleId;
  final DateTime completeTime;

  AddProgress(this.scheduleId, this.completeTime);
}

class ProgressBloc extends Bloc<ProgressEvent, Map<int, Progress>> {
  final ProgressRepository _progressRepository;

  DateTime _currentDate = DateTimeUtils.truncateToDay(DateTime.now());

  ProgressBloc(this._progressRepository) : super({}) {
    on<UpdateProgressDate>((event, emit) async {
      _currentDate = DateTime.now();
      final progressMap = await _progressRepository.getProgressMap(_currentDate);
      emit(progressMap);
    });
    on<AddProgress>((event, emit) async {
      _handleAddProgress(event);
      final progressMap = await _progressRepository.getProgressMap(_currentDate);
      emit(progressMap);
    });
  }

  void _handleAddProgress(AddProgress e) {
    _progressRepository.addProgress(e.scheduleId, e.completeTime);
  }
}
