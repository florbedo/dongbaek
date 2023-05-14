import 'package:grpc/grpc.dart';

ClientChannel getGrpcClientChannel() {
  return ClientChannel(
    'localhost',
    port: 9090,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );
}
