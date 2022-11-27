import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ScheduleEvent {
  const ScheduleEvent();
}

class RefreshSchedules extends ScheduleEvent {
  final DateTime? dateTime;

  RefreshSchedules({this.dateTime});
}

class AddSchedule extends ScheduleEvent {
  final String title;
  final Goal goal;
  final RepeatInfo repeatInfo;
  final DateTime startDate;
  final DateTime? dueDate;

  AddSchedule(this.title, this.goal, this.repeatInfo, this.startDate, this.dueDate);
}

class RemoveSchedule extends ScheduleEvent {
  final ScheduleId scheduleId;

  RemoveSchedule(this.scheduleId);
}

class ScheduleBloc extends Bloc<ScheduleEvent, List<Schedule>> {
  final ScheduleRepository _scheduleRepository;

  DateTime _dateTime = DateTime.now();

  ScheduleBloc(this._scheduleRepository) : super([]) {
    on<RefreshSchedules>((event, emit) async {
      _dateTime = event.dateTime ?? _dateTime;
      final snapshots = await _getSchedules(_dateTime);
      emit(snapshots);
    });
    on<AddSchedule>((event, emit) async {
      await _handleAddSchedule(event);
      add(RefreshSchedules());
    });
    on<RemoveSchedule>((event, emit) async {
      await _handleRemoveSchedule(event);
      add(RefreshSchedules());
    });

    add(RefreshSchedules());
  }

  Future<List<Schedule>> _getSchedules(DateTime dateTime) async {
    return await _scheduleRepository.getSchedules(dateTime);
  }

  Future<void> _handleAddSchedule(AddSchedule e) async {
    final id = await _scheduleRepository.nextScheduleId();
    Schedule newSchedule = Schedule(id, e.title, e.goal, e.repeatInfo, e.startDate);
    await _scheduleRepository.addSchedule(newSchedule);
  }

  Future<void> _handleRemoveSchedule(RemoveSchedule e) async {
    await _scheduleRepository.removeSchedule(e.scheduleId);
  }
}
