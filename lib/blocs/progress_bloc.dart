import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/services/progress_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProgressEvent {}

class AddProgressEvent extends ProgressEvent {
  final int scheduleId;
  final DateTime completeTime;

  AddProgressEvent(this.scheduleId, this.completeTime);
}

class ProgressBloc extends Bloc<ProgressEvent, Map<int, List<Progress>>> {
  final ProgressService _progressService = ProgressService();

  ProgressBloc() : super({}) {
    on<AddProgressEvent>((event, emit) {
      _handleAddProgress(event);
      emit(_progressService.progressMap);
    });
  }

  void _handleAddProgress(AddProgressEvent e) {
    Progress newProgress = Progress(e.scheduleId, e.completeTime);
    _progressService.addProgress(newProgress);
  }
}
