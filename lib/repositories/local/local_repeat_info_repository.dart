import 'dart:convert';

import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/proto/google/protobuf/timestamp.pb.dart' as pb_timestamp;
import 'package:dongbaek/proto/repeat_info_data.pb.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalRepeatInfoRepository {
  final _sf = SharedPreferences.getInstance();

  Future<RepeatInfo> getRepeatInfo(int scheduleId) async {
    final key = _formatRepeatInfoKey(scheduleId);
    final repeatInfoCont = await _getRepeatInfoCont(key);
    switch (repeatInfoCont.whichData()) {
      case RepeatInfoDataContainer_Data.once:
        final startDate = repeatInfoCont.once.startDate.toDateTime();
        final ended = repeatInfoCont.once.ended;
        return Once(startDate, ended: ended);
      case RepeatInfoDataContainer_Data.onceByInterval:
        final startDate = repeatInfoCont.onceByInterval.startDate.toDateTime();
        final intervalDays = repeatInfoCont.onceByInterval.intervalDays;
        final ended = repeatInfoCont.onceByInterval.ended;
        return OnceByInterval(startDate, intervalDays, ended: ended);
      case RepeatInfoDataContainer_Data.quantityByPeriod:
        final startDate = repeatInfoCont.quantityByPeriod.startDate.toDateTime();
        final periodDays = repeatInfoCont.quantityByPeriod.periodDays;
        final quantity = repeatInfoCont.quantityByPeriod.quantity;
        final ended = repeatInfoCont.quantityByPeriod.ended;
        return QuantityByPeriod(startDate, periodDays, quantity, ended: ended);
      case RepeatInfoDataContainer_Data.durationByPeriod:
        final startDate = repeatInfoCont.durationByPeriod.startDate.toDateTime();
        final periodDays = repeatInfoCont.durationByPeriod.periodDays;
        final duration = Duration(seconds: repeatInfoCont.durationByPeriod.durationSec);
        final ended = repeatInfoCont.durationByPeriod.ended;
        return DurationByPeriod(startDate, periodDays, duration, ended: ended);
      default:
        throw UnimplementedError("INVALID_REPEAT_INFO_DATA_CONTAINER ${repeatInfoCont.toString()}");
    }
  }

  Future<void> setRepeatInfo(int scheduleId, RepeatInfo repeatInfo) async {
    final key = _formatRepeatInfoKey(scheduleId);
    await (await _sf).setString(key, base64Encode(_encodeRepeatInfo(repeatInfo).writeToBuffer()));
  }

  String _formatRepeatInfoKey(int scheduleId) => "repeatInfo_$scheduleId";

  Future<RepeatInfoDataContainer> _getRepeatInfoCont(String key) async {
    final repeatInfoContBase64 = (await _sf).getString(key)!;
    return RepeatInfoDataContainer.fromBuffer(base64Decode(repeatInfoContBase64));
  }

  RepeatInfoDataContainer _encodeRepeatInfo(RepeatInfo repeatInfo) {
    final startDate = pb_timestamp.Timestamp.fromDateTime(repeatInfo.startDate);
    if (repeatInfo is Once) {
      return RepeatInfoDataContainer(once: OnceData(startDate: startDate, ended: repeatInfo.ended));
    }
    if (repeatInfo is OnceByInterval) {
      final data =
          OnceByIntervalData(startDate: startDate, intervalDays: repeatInfo.intervalDays, ended: repeatInfo.ended);
      return RepeatInfoDataContainer(onceByInterval: data);
    }
    if (repeatInfo is QuantityByPeriod) {
      final data = QuantityByPeriodData(
          startDate: startDate,
          periodDays: repeatInfo.periodDays,
          quantity: repeatInfo.quantity,
          ended: repeatInfo.ended);
      return RepeatInfoDataContainer(quantityByPeriod: data);
    }
    if (repeatInfo is DurationByPeriod) {
      final data = DurationByPeriodData(
          startDate: startDate,
          periodDays: repeatInfo.periodDays,
          durationSec: repeatInfo.duration.inSeconds,
          ended: repeatInfo.ended);
      return RepeatInfoDataContainer(durationByPeriod: data);
    }
    // Should never reach here
    throw UnimplementedError("UNABLE_TO_ENCODE_REPEAT_INFO $repeatInfo");
  }
}
