import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_client.dart' show MqttClientPayloadBuilder;
import 'package:mqtt_client/mqtt_server_client.dart';

class UCPClient {
  final String brokerAddress;
  final String deviceId;
  final int port;
  late MqttServerClient _client;

  UCPClient({
    required this.brokerAddress,
    required this.deviceId,
    this.port = 1883,
  }) {
    _client = MqttServerClient(brokerAddress, deviceId)
      ..logging(on: true)
      ..logging(on: true)
      ..keepAlivePeriod = 20
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onSubscribed = _onSubscribed
      ..onSubscribeFail = _onSubscribeFail;
  }

  Future<void> connect() async {
    try {
      await _client.connect();
    } on Exception catch (e) {
      print('[UCPClient] Connection failed: $e');
      disconnect();
    }
  }

  void subscribe(String topic) {
    try {
      _client.subscribe(topic, MqttQos.atLeastOnce);
      print('[UCPClient] Subscribed to $topic');
    } catch (e) {
      print('[UCPClient] Subscription failed: $e');
    }
  }

  void publish(String topic, String message) {
    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('[UCPClient] Published to $topic: $message');
    } catch (e) {
      print('[UCPClient] Publish failed: $e');
    }
  }

  void setMessageHandler(Function(String topic, String message) handler) {
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (var message in messages) {
        final MqttPublishMessage recMess =
            message.payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        handler(message.topic, payload);
      }
    });
  }

  void disconnect() {
    _client.disconnect();
    print('[UCPClient] Disconnected');
  }

  void _onConnected() {
    print('[UCPClient] Connected to MQTT broker');
  }

  void _onDisconnected() {
    print('[UCPClient] Disconnected from MQTT broker');
  }

  void _onSubscribed(String topic) {
    print('[UCPClient] Subscribed to topic: $topic');
  }

  void _onSubscribeFail(String topic) {
    print('[UCPClient] Failed to subscribe to topic: $topic');
  }
}
