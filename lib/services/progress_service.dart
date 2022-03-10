import 'package:dongbaek/models/progress.dart';

class ProgressService {
  static const int epochDayDivisor = 24 * 3600 * 1000;

  final Map<int, Map<int, Progress>> _progressStatus = {};

  static int getEpochDay(DateTime dateTime) {
    return (dateTime.millisecondsSinceEpoch + dateTime.timeZoneOffset.inMilliseconds) ~/ epochDayDivisor;
  }

  Map<int, Progress> getProgressMap(DateTime dateTime) {
    final epochDay = getEpochDay(dateTime);
    return Map.unmodifiable(_progressStatus[epochDay] ?? {});
  }

  void addProgress(int scheduleId, DateTime completeDateTime) {
    final epochDay = getEpochDay(completeDateTime);
    _progressStatus.update(
      epochDay,
      (progressMap) {
        progressMap.update(
          scheduleId,
          (progress) => Progress(progress.completeTimes + [completeDateTime]),
          ifAbsent: () => Progress([completeDateTime]),
        );
        return progressMap;
      },
      ifAbsent: () => {
        scheduleId: Progress([completeDateTime])
      },
    );
  }
}
