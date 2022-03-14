import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/schedule.dart';
import '../services/schedule_service.dart';
import '../utils/counter.dart';

abstract class ScheduleEvent {
  const ScheduleEvent();
}

class UpdateScheduleDate extends ScheduleEvent {
  const UpdateScheduleDate();
}

class AddSchedule extends ScheduleEvent {
  final String title;
  final List<DayOfWeek> selectedDaysOfWeek;
  final int repeatCount;

  AddSchedule(this.title, this.selectedDaysOfWeek, this.repeatCount);
}

class RemoveSchedule extends ScheduleEvent {
  final int targetId;

  RemoveSchedule(this.targetId);
}

class ScheduleBloc extends Bloc<ScheduleEvent, List<Schedule>> {
  final ScheduleService _scheduleService = ScheduleService();

  DateTime _currentDate = DateTimeUtils.truncateToDay(DateTime.now());

  ScheduleBloc() : super([]) {
    on<UpdateScheduleDate>((event, emit) {
      _currentDate = DateTimeUtils.truncateToDay(DateTime.now());
    });
    on<AddSchedule>((event, emit) {
      _handleAddSchedule(event);
      emit(_scheduleService.getSchedules(DateTimeUtils.getDayOfWeek(_currentDate)));
    });
    on<RemoveSchedule>((event, emit) {
      _handleRemoveSchedule(event);
      emit(_scheduleService.getSchedules(DateTimeUtils.getDayOfWeek(_currentDate)));
    });
  }

  void _handleAddSchedule(AddSchedule e) {
    final repeatInfo =
        e.selectedDaysOfWeek.isEmpty ? RepeatPerWeek(e.repeatCount) : RepeatPerDay(e.repeatCount, e.selectedDaysOfWeek);
    Schedule newSchedule = Schedule(Counter.next(), e.title, repeatInfo);
    _scheduleService.addSchedule(newSchedule);
  }

  void _handleRemoveSchedule(RemoveSchedule e) {
    _scheduleService.removeSchedule(e.targetId);
  }
}
