import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/utils/datetime_utils.dart';

class ProgressService {
  final Map<int, Map<int, Progress>> _progressStatus = {};

  Map<int, Progress> getProgressMap(DateTime currentDate) {
    final currentEpochDay = DateTimeUtils.asEpochDay(currentDate);
    return Map.unmodifiable(_progressStatus[currentEpochDay] ?? {});
  }

  void addProgress(int scheduleId, DateTime completeDateTime) {
    final epochDay = DateTimeUtils.asEpochDay(completeDateTime);
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
