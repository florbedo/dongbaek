import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/services/progress_service.dart';
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
  final ProgressService _progressService;

  DateTime _currentDate = DateTimeUtils.truncateToDay(DateTime.now());

  ProgressBloc(this._progressService) : super({}) {
    on<UpdateProgressDate>((event, emit) {
      _currentDate = DateTime.now();
      emit(_progressService.getProgressMap(_currentDate));
    });
    on<AddProgress>((event, emit) {
      _handleAddProgress(event);
      emit(_progressService.getProgressMap(_currentDate));
    });
  }

  void _handleAddProgress(AddProgress e) {
    _progressService.addProgress(e.scheduleId, e.completeTime);
  }
}
