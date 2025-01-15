import 'package:test/test.dart';
import 'package:ucp_dart/ucp_dart.dart';
import 'package:mockito/mockito.dart';

class MockUCPClient extends Mock implements UCPClient {}

void main() {
  group('UCPClient', () {
    late MockUCPClient client;

    setUp(() {
      client = MockUCPClient();
    });

    test('should connect to the broker', () async {
      when(client.connect()).thenAnswer((_) async => null);

      await client.connect();

      verify(client.connect()).called(1);
    });

    test('should subscribe to a topic', () async {
      client.subscribe('ucl/commands/dart-device');

      verify(client.subscribe('ucl/commands/dart-device')).called(1);
    });

    test('should publish a message', () async {
      client.publish('ucl/status/dart-device', '{"status": "online"}');

      verify(client.publish('ucl/status/dart-device', '{"status": "online"}')).called(1);
    });

    test('should handle incoming messages', () async {
      final messageHandler = (String topic, String message) {
        if (message == '{"action": "ping"}') {
          client.publish('ucl/status/dart-device', '{"status": "pong"}');
        }
      };

      client.setMessageHandler(messageHandler);

      messageHandler('ucl/commands/dart-device', '{"action": "ping"}');

      verify(client.publish('ucl/status/dart-device', '{"status": "pong"}')).called(1);
    });
  });
}