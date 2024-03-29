import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/proto/models.pb.dart';
import 'package:dongbaek/repositories/local/local_database.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';
import 'package:dongbaek/utils/pb_utils.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class LocalScheduleRepository implements ScheduleRepository {
  final uuid = const Uuid();
  final LocalDatabase _localDatabase = LocalDatabase();

  ScheduleId nextId() {
    return ScheduleId(uuid.v1());
  }

  @override
  Future<Schedule> getSchedule(ScheduleId scheduleId) async {
    final scheduleContainer = await _localDatabase.findScheduleContainer(scheduleId);
    return PbSchedule.fromJson(scheduleContainer.scheduleProtoJson).toSchedule();
  }

  @override
  Future<List<Schedule>> getSchedules(DateTime currentDate) async {
    final scheduleContainers = await _localDatabase.findScheduleContainers(currentDate);
    return scheduleContainers
        .map((container) => PbSchedule.fromJson(container.scheduleProtoJson))
        .map((scheduleData) => scheduleData.toSchedule())
        .toList();
  }

  @override
  Future<void> addSchedule(ScheduleData s) async {
    final id = nextId();
    final schedule = s.toSchedule(id);
    final inserting = ScheduleContainerCompanion.insert(
        id: id.value,
        startDate: s.startDateTime.toUtc(),
        dueDate: Value(s.dueDateTime?.toUtc()),
        finishDate: Value(s.finishDateTime?.toUtc()),
        scheduleProtoJson: schedule.toPbSchedule().writeToJson());
    await _localDatabase.replaceScheduleContainer(inserting);
  }

  @override
  Future<void> completeSchedule(ScheduleId scheduleId, DateTime endDateTime) async {
    final scheduleContainer = await _localDatabase.findScheduleContainer(scheduleId);
    final pbSchedule = PbSchedule.fromJson(scheduleContainer.scheduleProtoJson);
    pbSchedule.finishTimestamp = endDateTime.toPbTimestamp();

    final replacing = ScheduleContainerCompanion.insert(
        id: scheduleId.value,
        startDate: scheduleContainer.startDate,
        dueDate: Value(scheduleContainer.dueDate),
        finishDate: Value(scheduleContainer.finishDate),
        scheduleProtoJson: pbSchedule.writeToJson());
    await _localDatabase.replaceScheduleContainer(replacing);
  }

  @override
  Future<void> removeSchedule(ScheduleId scheduleId) async {
    await _localDatabase.deleteScheduleContainer(scheduleId);
  }
}
