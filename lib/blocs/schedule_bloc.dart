import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';
import 'package:dongbaek/utils/counter.dart';
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
    on<AddSchedule>((event, emit) {
      _handleAddSchedule(event);
      emit(_scheduleRepository.getSchedules(_currentDate));
    });
    on<RemoveSchedule>((event, emit) {
      _handleRemoveSchedule(event);
      emit(_scheduleRepository.getSchedules(_currentDate));
    });
  }

  void _handleAddSchedule(AddSchedule e) {
    final repeatInfo =
        e.selectedDaysOfWeek.isEmpty ? RepeatPerWeek(e.repeatCount) : RepeatPerDay(e.repeatCount, e.selectedDaysOfWeek);
    Schedule newSchedule = Schedule(Counter.next(), e.title, repeatInfo);
    _scheduleRepository.addSchedule(newSchedule);
  }

  void _handleRemoveSchedule(RemoveSchedule e) {
    _scheduleRepository.removeSchedule(e.targetId);
  }
}
