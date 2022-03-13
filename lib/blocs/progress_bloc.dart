import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/services/progress_service.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProgressEvent {}

class UpdateEpochDay extends ProgressEvent {
  final DateTime currentDateTime;

  UpdateEpochDay(this.currentDateTime);
}

class AddProgressEvent extends ProgressEvent {
  final int scheduleId;
  final DateTime completeTime;

  AddProgressEvent(this.scheduleId, this.completeTime);
}

class ProgressBloc extends Bloc<ProgressEvent, Map<int, Progress>> {
  final ProgressService _progressService = ProgressService();

  int _currentEpochDay = DateTimeUtils.asEpochDay(DateTime.now());

  ProgressBloc() : super({}) {
    on<UpdateEpochDay>((event, emit) {
      _currentEpochDay = DateTimeUtils.asEpochDay(event.currentDateTime);
      emit(_progressService.getProgressMap(_currentEpochDay));
    });
    on<AddProgressEvent>((event, emit) {
      _handleAddProgress(event);
      emit(_progressService.getProgressMap(_currentEpochDay));
    });
  }

  void _handleAddProgress(AddProgressEvent e) {
    _progressService.addProgress(e.scheduleId, e.completeTime);
  }
}
