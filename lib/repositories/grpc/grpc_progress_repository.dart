import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/proto/grpc.pbgrpc.dart';
import 'package:dongbaek/repositories/grpc/client_channel.dart';
import 'package:dongbaek/repositories/progress_repository.dart';
import 'package:dongbaek/utils/pb_utils.dart';

class GrpcProgressRepository implements ProgressRepository {
  final progressServiceApi = ProgressServiceClient(getGrpcClientChannel());

  @override
  Future<Map<ScheduleId, Progress>> getProgresses(Iterable<ScheduleId> scheduleIds, DateTime targetDate) async {
    final ids = scheduleIds.map((id) => id.value);
    final request = GetProgressesRequest(scheduleIds: ids, timestamp: targetDate.toPbTimestamp());
    final response = await progressServiceApi.getProgresses(request);
    return Map.fromEntries(response.progresses
        .map((pbProgress) => pbProgress.toProgress())
        .map((progress) => MapEntry(progress.scheduleId, progress)));
  }

  @override
  Future<void> replaceProgress(Progress progress) async {
    final request = ReplaceProgressRequest(progress: progress.toPbProgress());
    await progressServiceApi.replaceProgress(request);
  }
}
