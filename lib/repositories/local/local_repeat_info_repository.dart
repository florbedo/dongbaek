import 'dart:convert';

import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/utils/datetime_utils.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocalRepeatInfoRepository {
  final _sf = SharedPreferences.getInstance();

  Future<RepeatInfo> getRepeatInfo(int scheduleId) async {
    final key = _formatRepeatInfoKey(scheduleId);
    final jsonString = (await _sf).getString(key)!;
    return _decodeRepeatInfo(jsonString);
  }

  Future<void> setRepeatInfo(int scheduleId, RepeatInfo repeatInfo) async {
    final key = _formatRepeatInfoKey(scheduleId);
    await (await _sf).setString(key, _encodeRepeatInfo(repeatInfo));
  }

  String _formatRepeatInfoKey(int scheduleId) => "repeatInfo_$scheduleId";

  String _encodeRepeatInfo(RepeatInfo repeatInfo) {
    switch (repeatInfo.runtimeType) {
      case RepeatPerDay:
        final repeatPerDay = repeatInfo as RepeatPerDay;
        final map = Map.fromEntries([
          const MapEntry("type", RepeatPerDay.repeatType),
          MapEntry("repeatCount", repeatPerDay.repeatCount),
          MapEntry("daysOfWeek", repeatPerDay.daysOfWeek.map((e) => e.name).toList()),
        ]);
        return jsonEncode(map);
      case RepeatPerWeek:
        final repeatPerWeek = repeatInfo as RepeatPerWeek;
        final map = Map.fromEntries([
          const MapEntry("type", RepeatPerWeek.repeatType),
          MapEntry("repeatCount", repeatPerWeek.repeatCount),
        ]);
        return jsonEncode(map);
    }
    // Should never reach here
    throw UnimplementedError("UNABLE_TO_ENCODE_REPEAT_INFO $repeatInfo");
  }

  RepeatInfo _decodeRepeatInfo(String jsonString) {
    final Map<String, dynamic> map = jsonDecode(jsonString);
    switch (map["type"]) {
      case RepeatPerDay.repeatType:
        final repeatCount = map["repeatCount"];
        final List<String> daysOfWeek = (map["daysOfWeek"] as List).map((e) => e as String).toList();
        return RepeatPerDay(repeatCount, daysOfWeek.map((name) => DateTimeUtils.dayOfWeekFromName(name)).toList());
      case RepeatPerWeek.repeatType:
        final repeatCount = map["repeatCount"];
        return RepeatPerWeek(repeatCount);
    }
    // Should never reach here
    throw UnimplementedError("UNABLE_TO_DECODE_REPEAT_INFO $jsonString");
  }
}
