import 'dart:html';
import 'dart:async';
import 'dart:convert' show JSON;
import './shared/playerEntity.dart';

/// Connection class
/// Handles player's connection to server in order to interact with others.
class Connection {

  /// Server address constant.
  static const String SERVER_ADDRESS = "localhost";
  /// Server port constant.
  static const int SERVER_PORT = 9999;
  /// Wait time before attempt to reconnect to server (upon socket close).
  static const int RECONENCT_WAIT = 250; // ms
  /// Player's socket connection to server.
  WebSocket ws;
  /// Handler function for onOpen event.
  Function connectedHandler;
  /// Handler function for onMessage event.
  Function messageHandler;


  /// Default constructor.
  Connection(this.connectedHandler, this.messageHandler) {
    init();
  }

  /// Initialization method.
  void init() {
    // Open new socket on server address and port.
    ws = new WebSocket("ws://$SERVER_ADDRESS:$SERVER_PORT");

    // Setup onOpen event handler.
    ws.onOpen.listen(connectedHandler);
    // Setup onMessage event handler.
    ws.onMessage.listen(messageHandler);
    // Setup onClose event handler.
    ws.onClose.listen(connectionClose);
  }

  void sendPlayer(PlayerEntity pe) {
    ws.send(pe.getJson());
  }

  /// Server closed connection event handler.
  void connectionClose(Event e) {
    // Attempt to reconnect to server after waiting for RECONENCT_WAIT milliseconds,
    //  this handler is being called until server connection is reestablished.
    new Timer(const Duration(milliseconds: RECONENCT_WAIT), init);
  }
}
