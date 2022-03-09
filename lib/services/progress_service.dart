import 'package:dongbaek/models/progress.dart';

class ProgressService {
  final Map<int, List<Progress>> _progressMap = {};

  Map<int, List<Progress>> get progressMap {
    return Map.unmodifiable(_progressMap);
  }

  void addProgress(Progress progress) {
    _progressMap.update(
      progress.scheduleId,
      (progressList) {
        return progressList + [progress];
      },
      ifAbsent: () {
        return [progress];
      },
    );
  }
}
