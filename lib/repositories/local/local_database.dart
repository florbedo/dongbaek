import 'dart:developer' as dev;

import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:drift/drift.dart';

import 'connection/connection.dart' as conn;

part 'local_database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase._construct(QueryExecutor e) : super(e);

  static final LocalDatabase _instance = LocalDatabase._construct(conn.openConnection());

  factory LocalDatabase() {
    return _instance;
  }

  Future<ScheduleContainerData> findScheduleContainer(ScheduleId scheduleId) =>
      (select(scheduleContainer)..where((t) => t.id.equals(scheduleId.value))).getSingle();

  Future<List<ScheduleContainerData>> findScheduleContainers(DateTime date) =>
      (select(scheduleContainer)..where((t) => t.startDate.isSmallerOrEqual(Variable(date)))).get();

  // Future<int> insertScheduleContainer(ScheduleContainerCompanion data) => into(scheduleContainer).insert(data);

  Future<int> replaceScheduleContainer(ScheduleContainerCompanion data) =>
      into(scheduleContainer).insertOnConflictUpdate(data);

  Future<int> deleteScheduleContainer(ScheduleId scheduleId) =>
      (delete(scheduleContainer)..where((t) => t.id.equals(scheduleId.value))).go();

  Future<List<ProgressContainerData>> findProgresses() => (select(progressContainer).get());

  Future<ProgressContainerData> findProgress(ProgressId progressId) =>
      (select(progressContainer)..where((t) => t.id.equals(progressId.value))).getSingle();

  Future<ProgressContainerData?> findProgressContainerBySchedule(ScheduleId scheduleId, DateTime date) =>
      (select(progressContainer)
            ..where((t) =>
                t.scheduleId.equals(scheduleId.value) &
                t.startDate.isSmallerOrEqual(Variable(date)) &
                (t.endDate.isBiggerOrEqual(Variable(date)) | t.endDate.isNull()))
            ..orderBy([(t) => OrderingTerm.desc(progressContainer.startDate)]))
          .getSingleOrNull();

  Future<int> replaceProgressContainer(ProgressContainerCompanion data) =>
      into(progressContainer).insertOnConflictUpdate(data);

  Future<void> printDatabase() async {
    for (final tblInfo in allTables) {
      final data = await tblInfo.select().get();
      dev.log("${tblInfo.entityName} $data");
    }
  }

  void truncateDatabase() {
    for (final tblInfo in allTables) {
      tblInfo.deleteAll();
    }
  }

  @override
  int get schemaVersion => 1;
}
