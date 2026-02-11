import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketHandler {
  final List<WebSocketChannel> _clients = [];

  Handler get handler {
    return webSocketHandler((WebSocketChannel webSocket) {
      _clients.add(webSocket);

      webSocket.stream.listen(
        (message) {
          // Handle incoming messages (e.g., ping/pong, client status)
        },
        onDone: () {
          _clients.remove(webSocket);
        },
        onError: (error) {
          _clients.remove(webSocket);
        },
      );
    });
  }

  void broadcast(String message) {
    for (final client in _clients) {
      client.sink.add(message);
    }
  }
}
