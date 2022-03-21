import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase._construct(QueryExecutor e) : super(e);

  static final LocalDatabase _instance = LocalDatabase._construct(_openConnection());

  factory LocalDatabase() {
    return _instance;
  }

  Future<List<ScheduleMetaData>> findAllScheduleMetaEntries() => select(scheduleMeta).get();

  Future<int> insertScheduleMeta(ScheduleMetaCompanion data) => into(scheduleMeta).insert(data);

  Future<int> deleteScheduleMeta(int scheduleId) => (delete(scheduleMeta)..where((t) => t.id.equals(scheduleId))).go();

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
