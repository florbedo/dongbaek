import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/services/progress_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProgressEvent {}

class AddProgressEvent extends ProgressEvent {
  final int scheduleId;
  final DateTime completeTime;

  AddProgressEvent(this.scheduleId, this.completeTime);
}

class ProgressBloc extends Bloc<ProgressEvent, Map<int, Progress>> {
  final ProgressService _progressService = ProgressService();

  // TODO: Make ticker service?
  final DateTime _currentDateTime = DateTime.now();

  ProgressBloc() : super({}) {
    on<AddProgressEvent>((event, emit) {
      _handleAddProgress(event);
      emit(_progressService.getProgressMap(_currentDateTime));
    });
  }

  void _handleAddProgress(AddProgressEvent e) {
    _progressService.addProgress(e.scheduleId, e.completeTime);
  }
}
