import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/schedule.dart';
import '../services/schedule_service.dart';
import '../utils/counter.dart';

abstract class ScheduleEvent {}

class AddScheduleEvent extends ScheduleEvent {
  final String title;
  final CycleUnitType cycleUnitType;

  AddScheduleEvent(this.title, this.cycleUnitType);
}

class RemoveScheduleEvent extends ScheduleEvent {
  final int targetId;

  RemoveScheduleEvent(this.targetId);
}

class ScheduleBloc extends Bloc<ScheduleEvent, List<Schedule>> {
  final ScheduleService _scheduleService = ScheduleService();

  ScheduleBloc() : super([]) {
    on<AddScheduleEvent>((event, emit) {
      _handleAddSchedule(event);
      emit(_scheduleService.schedules);
    });
    on<RemoveScheduleEvent>((event, emit) {
      _handleRemoveSchedule(event);
      emit(_scheduleService.schedules);
    });
  }

  void _handleAddSchedule(AddScheduleEvent e) {
    Schedule newSchedule = Schedule(Counter.next(), e.title, e.cycleUnitType);
    _scheduleService.addSchedule(newSchedule);
  }

  void _handleRemoveSchedule(RemoveScheduleEvent e) {
    _scheduleService.removeSchedule(e.targetId);
  }
}
