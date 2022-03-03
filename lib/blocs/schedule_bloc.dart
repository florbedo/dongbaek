import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/schedule.dart';
import '../utils/counter.dart';

abstract class ScheduleEvent {}

class AddScheduleEvent extends ScheduleEvent {
  final String title;

  AddScheduleEvent(this.title);
}

class RemoveScheduleEvent extends ScheduleEvent {
  final int targetId;

  RemoveScheduleEvent(this.targetId);
}

class ScheduleBloc extends Bloc<ScheduleEvent, List<Schedule>> {
  List<Schedule> schedules = [];

  ScheduleBloc() : super([]) {
    on<AddScheduleEvent>((event, emit) {
      _handleAddSchedule(event);
      emit(schedules);
    });
    on<RemoveScheduleEvent>((event, emit) {
      _handleRemoveSchedule(event);
      emit(schedules);
    });
  }

  void _handleAddSchedule(AddScheduleEvent e) {
    Schedule newSchedule = Schedule(Counter.next(), e.title);
    schedules = schedules + [newSchedule];
  }

  void _handleRemoveSchedule(RemoveScheduleEvent e) {
    schedules = schedules.where((element) => element.id != e.targetId).toList();
  }
}
