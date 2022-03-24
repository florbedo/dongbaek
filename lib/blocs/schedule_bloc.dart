import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ScheduleEvent {
  const ScheduleEvent();
}

class UpdateScheduleDate extends ScheduleEvent {
  const UpdateScheduleDate();
}

class AddSchedule extends ScheduleEvent {
  final String title;
  final List<DayOfWeek> selectedDaysOfWeek;
  final DateTime startDate;
  final int repeatCount;

  AddSchedule(this.title, this.selectedDaysOfWeek, this.startDate, this.repeatCount);
}

class RemoveSchedule extends ScheduleEvent {
  final int targetId;

  RemoveSchedule(this.targetId);
}

class ScheduleBloc extends Bloc<ScheduleEvent, List<Schedule>> {
  final ScheduleRepository _scheduleRepository;

  DateTime _currentDate = DateTimeUtils.truncateToDay(DateTime.now());

  ScheduleBloc(this._scheduleRepository) : super([]) {
    on<UpdateScheduleDate>((event, emit) {
      _currentDate = DateTimeUtils.truncateToDay(DateTime.now());
    });
    on<AddSchedule>((event, emit) async {
      await _handleAddSchedule(event);
      final schedules = await _scheduleRepository.getSchedules(_currentDate);
      emit(schedules);
    });
    on<RemoveSchedule>((event, emit) async {
      await _handleRemoveSchedule(event);
      final schedules = await _scheduleRepository.getSchedules(_currentDate);
      emit(schedules);
    });
  }

  Future<void> _handleAddSchedule(AddSchedule e) async {
    final repeatInfo =
        e.selectedDaysOfWeek.isEmpty ? RepeatPerWeek(e.repeatCount) : RepeatPerDay(e.repeatCount, e.selectedDaysOfWeek);
    Schedule newSchedule = Schedule(null, e.title, repeatInfo, e.startDate);
    await _scheduleRepository.addSchedule(newSchedule);
  }

  Future<void> _handleRemoveSchedule(RemoveSchedule e) async {
    await _scheduleRepository.removeSchedule(e.targetId);
  }
}
