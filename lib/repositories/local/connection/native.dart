import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dbDir = await getApplicationDocumentsDirectory();
    log("DB_DIRECTORY: $dbDir");
    final file = File(p.join(dbDir.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
