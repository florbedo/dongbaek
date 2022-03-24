import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/repositories/local/local_database.dart';
import 'package:dongbaek/repositories/local/local_repeat_info_repository.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';

class LocalScheduleRepository implements ScheduleRepository {
  final LocalDatabase _localDatabase = LocalDatabase();
  final LocalRepeatInfoRepository _localRepeatInfoRepository = LocalRepeatInfoRepository();

  final Map<int, RepeatInfo> _repeatInfoMap = {};

  Future<Schedule> _fromScheduleMetaData(ScheduleMetaData scheduleMeta) async {
    final repeatInfo = await _localRepeatInfoRepository.getRepeatInfo(scheduleMeta.id);
    return Schedule(scheduleMeta.id, scheduleMeta.title, repeatInfo, scheduleMeta.startDate);
  }

  @override
  Future<List<Schedule>> getSchedules(DateTime currentDate) async {
    final scheduleMetaList = await _localDatabase.findScheduleMetaData(currentDate);
    return Stream.fromFutures(scheduleMetaList.map((scheduleMeta) => _fromScheduleMetaData(scheduleMeta))).toList();
  }

  @override
  Future<void> addSchedule(Schedule schedule) async {
    final inserting = ScheduleMetaCompanion.insert(title: schedule.title, startDate: schedule.startDate);
    final scheduleId = await _localDatabase.insertScheduleMeta(inserting);
    _localRepeatInfoRepository.setRepeatInfo(scheduleId, schedule.repeatInfo);
  }

  @override
  Future<void> removeSchedule(int scheduleId) async {
    _repeatInfoMap.remove(scheduleId);
    await _localDatabase.deleteScheduleMeta(scheduleId);
  }
}
