import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _eventController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get events => _eventController.stream;

  void connect(String url) {
    debugPrint('🔌 Connecting to WebSocket: $url');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen(
        (message) {
          debugPrint('📥 WebSocket received: $message');
          try {
            final data = jsonDecode(message);
            if (data is Map<String, dynamic>) {
              _eventController.add(data);
            }
          } catch (e) {
            debugPrint('❌ Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('❌ WebSocket Error: $error');
          // Implement reconnection logic if needed
        },
        onDone: () {
          debugPrint('🔌 WebSocket Disconnected');
          // Implement reconnection logic if needed
        },
      );
    } catch (e) {
      debugPrint('❌ WebSocket Connection Failed: $e');
    }
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    } else {
      debugPrint('⚠️ Cannot send message, WebSocket not connected');
    }
  }

  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}
