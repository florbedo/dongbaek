import '../models/progress.dart';

abstract class ProgressRepository {
  Map<int, Progress> getProgressMap(DateTime currentDate);
  void addProgress(int scheduleId, DateTime completeDateTime);
}
