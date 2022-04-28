import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/proto/progress_data.pb.dart';
import 'package:dongbaek/repositories/progress_repository.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProgressRepository implements ProgressRepository {
  final Future<SharedPreferences> _sf = SharedPreferences.getInstance();

  @override
  Future<Map<int, Progress>> getProgressMap(DateTime targetDate) async {
    final scheduleIds = await _findScheduleIds(targetDate);
    final entryFutures = scheduleIds.map((scheduleId) async {
      final key = _formatProgressKey(scheduleId, targetDate);
      final progressCont = await _findProgressCont(key);
      final progress = _extractProgress(progressCont);
      if (progress == null) {
        return null;
      }
      return MapEntry(scheduleId, progress);
    });
    final entries = (await Stream.fromFutures(entryFutures).toList()).whereNotNull();
    return Map.fromEntries(entries);
  }

  @override
  Future<void> updateQuantityProgress(int scheduleId, DateTime dateTime, int diff) async {
    await _addScheduleId(scheduleId, dateTime);
    final key = _formatProgressKey(scheduleId, dateTime);
    final newQuantity = (await _findCountProgress(key)).quantity + diff;
    final progressCont = ProgressDataContainer(quantityProgress: QuantityProgressData(quantity: newQuantity));
    (await _sf).setString(key, base64Encode(progressCont.writeToBuffer()));
  }

  @override
  Future<void> updateDurationProgress(int scheduleId, DateTime dateTime, Duration durationDiff) async {
    await _addScheduleId(scheduleId, dateTime);
    final key = _formatProgressKey(scheduleId, dateTime);
    final newDurationSec = (await _findDurationProgress(key)).duration.inSeconds + durationDiff.inSeconds;
    final progressCont = ProgressDataContainer(durationProgress: DurationProgressData(durationSec: newDurationSec));
    (await _sf).setString(key, base64Encode(progressCont.writeToBuffer()));
  }

  Progress? _extractProgress(ProgressDataContainer? progressCont) {
    if (progressCont == null) {
      return null;
    }
    switch (progressCont.whichData()) {
      case ProgressDataContainer_Data.onceProgress:
        return OnceProgress(progressCont.onceProgress.complete);
      case ProgressDataContainer_Data.quantityProgress:
        return QuantityProgress(progressCont.quantityProgress.quantity);
      case ProgressDataContainer_Data.durationProgress:
        return DurationProgress(Duration(seconds: progressCont.durationProgress.durationSec));
      default:
        throw UnimplementedError("INVALID_PROGRESS_DATA_CONTAINER $progressCont");
    }
  }

  Future<QuantityProgress> _findCountProgress(String key) async {
    final progressCont = await _findProgressCont(key);
    if (progressCont == null) {
      return QuantityProgress(0);
    }
    return QuantityProgress(progressCont.quantityProgress.quantity);
  }

  Future<DurationProgress> _findDurationProgress(String key) async {
    final progressCont = await _findProgressCont(key);
    if (progressCont == null) {
      return DurationProgress(Duration.zero);
    }
    final duration = Duration(seconds: progressCont.durationProgress.durationSec);
    return DurationProgress(duration);
  }

  Future<ProgressDataContainer?> _findProgressCont(String key) async {
    final progressContBase64 = (await _sf).getString(key);
    if (progressContBase64 == null) {
      return null;
    }
    return ProgressDataContainer.fromBuffer(base64Decode(progressContBase64));
  }

  Future<List<int>> _findScheduleIds(DateTime date) async {
    final key = _formatScheduleIdsKey(date);
    return ((await _sf).getStringList(key)?.map((idStr) => int.parse(idStr)))?.toList() ?? [];
  }

  Future<void> _addScheduleId(int scheduleId, DateTime dateTime) async {
    final key = _formatScheduleIdsKey(dateTime);
    final beforeScheduleIds = await _findScheduleIds(dateTime);
    if (!beforeScheduleIds.contains(scheduleId)) {
      (await _sf).setStringList(key, (beforeScheduleIds + [scheduleId]).map((id) => id.toString()).toList());
    }
  }

  String _formatScheduleIdsKey(DateTime date) => "scheduleIds_${DateTimeUtils.asEpochDay(date)}";

  String _formatProgressKey(int scheduleId, DateTime date) =>
      "progresses_${scheduleId}_${DateTimeUtils.asEpochDay(date)}";
}
