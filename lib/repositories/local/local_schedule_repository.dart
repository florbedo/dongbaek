import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/repositories/local/local_database.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';

class LocalScheduleRepository implements ScheduleRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  final Map<int, RepeatInfo> _repeatInfoMap = {};

  Schedule _fromScheduleMetaData(ScheduleMetaData scheduleMeta) {
    // TODO: Store RepeatInfo with SharedPreference
    return Schedule(scheduleMeta.id, scheduleMeta.title, _repeatInfoMap[scheduleMeta.id] ?? RepeatPerWeek(1));
  }

  @override
  Future<List<Schedule>> getSchedules(DateTime currentDate) {
    return _localDatabase
        .findAllScheduleMetaEntries()
        .then((list) => list.map((e) => _fromScheduleMetaData(e)).toList());
  }

  @override
  Future<void> addSchedule(Schedule schedule) async {
    final inserting = ScheduleMetaCompanion.insert(title: schedule.title, startDate: DateTime.now());
    final scheduleId = await _localDatabase.insertScheduleMeta(inserting);
    _repeatInfoMap[scheduleId] = schedule.repeatInfo;
  }

  @override
  Future<void> removeSchedule(int scheduleId) async {
    _repeatInfoMap.remove(scheduleId);
    await _localDatabase.deleteScheduleMeta(scheduleId);
  }
}
