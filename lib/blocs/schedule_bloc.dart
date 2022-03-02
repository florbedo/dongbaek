import 'dart:async';

import 'package:dongbaek/models/schedule.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/counter.dart';

class ScheduleBloc {
  final StreamController<AddScheduleEvent> addScheduleSink =
      StreamController<AddScheduleEvent>();
  final StreamController<RemoveScheduleEvent> removeScheduleSink =
      StreamController<RemoveScheduleEvent>();

  final StreamController<List<Schedule>> _scheduleStreamController =
      BehaviorSubject<List<Schedule>>.seeded([]);

  Stream<List<Schedule>> get schedules => _scheduleStreamController.stream;

  List<Schedule> curSchedules = [];

  ScheduleBloc() {
    schedules.listen((data) {
      curSchedules = data;
    });
    addScheduleSink.stream.listen((_handleAddSchedule));
    removeScheduleSink.stream.listen((_handleRemoveSchedule));
  }

  void _handleAddSchedule(AddScheduleEvent e) {
    Schedule newSchedule = Schedule(Counter.next(), e.title);
    _scheduleStreamController.add(curSchedules + [newSchedule]);
  }

  void _handleRemoveSchedule(RemoveScheduleEvent e) {
    final filtered =
        curSchedules.where((element) => element.id != e.targetId).toList();
    _scheduleStreamController.add(filtered);
  }
}

class AddScheduleEvent {
  final String title;

  AddScheduleEvent(this.title);
}

class RemoveScheduleEvent {
  final int targetId;

  RemoveScheduleEvent(this.targetId);
}
