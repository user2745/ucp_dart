import 'package:ucp_dart/ucp_dart.dart';

void main() async {
  final client = UCPClient(
    brokerAddress: 'broker.emqx.io',
    deviceId: 'example-device',
  );

  await client.connect();

  client.subscribe('ucl/commands/example-device');

  client.setMessageHandler((topic, message) {
    print('Received on $topic: $message');
    if (message == '{"action": "ping"}') {
      client.publish('ucl/status/example-device', '{"status": "pong"}');
    }
  });

  client.publish('ucl/status/example-device', '{"status": "online"}');
}
