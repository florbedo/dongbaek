import 'dart:developer';
import 'dart:io';

import 'package:dongbaek/models/schedule.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase._construct(QueryExecutor e) : super(e);

  static final LocalDatabase _instance =
      LocalDatabase._construct(_openConnection());

  factory LocalDatabase() {
    return _instance;
  }

  Future<List<ScheduleContainerData>> findScheduleContainers(DateTime date) =>
      (select(scheduleContainer)
            ..where((t) => t.startDate.isSmallerOrEqual(Variable(date))))
          .get();

  Future<int> insertScheduleContainer(ScheduleContainerCompanion data) =>
      into(scheduleContainer).insert(data);

  Future<int> deleteScheduleContainer(ScheduleId scheduleId) =>
      (delete(scheduleContainer)..where((t) => t.id.equals(scheduleId.value)))
          .go();

  Future<ProgressContainerData?> findProgressContainer(
          ScheduleId scheduleId, DateTime date) =>
      (select(progressContainer)
            ..where((t) =>
                t.scheduleId.equals(scheduleId.value) &
                t.startDate.isSmallerOrEqual(Variable(date)) &
                t.endDate.isBiggerOrEqual(Variable(date))))
          .getSingleOrNull();

  Future<int> insertProgressContainer(ProgressContainerCompanion data) =>
      into(progressContainer).insert(data);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbDir = await getApplicationDocumentsDirectory();
    log("DB_DIRECTORY: $dbDir");
    final file = File(p.join(dbDir.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
