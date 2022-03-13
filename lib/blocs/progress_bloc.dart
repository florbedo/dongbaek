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
  final ProgressService _progressService = ProgressService();

  int _currentEpochDay = DateTimeUtils.asEpochDay(DateTime.now());

  ProgressBloc() : super({}) {
    on<UpdateProgressDate>((event, emit) {
      final currentDateTime = DateTime.now();
      _currentEpochDay = DateTimeUtils.asEpochDay(currentDateTime);
      emit(_progressService.getProgressMap(_currentEpochDay));
    });
    on<AddProgress>((event, emit) {
      _handleAddProgress(event);
      emit(_progressService.getProgressMap(_currentEpochDay));
    });
  }

  void _handleAddProgress(AddProgress e) {
    _progressService.addProgress(e.scheduleId, e.completeTime);
  }
}
