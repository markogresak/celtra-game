import "dart:io";
import "dart:convert";
/// import 'dart:convert' show JSON;
import '../web/dart/shared/playerEntity.dart';


/// PlayerManager class
/// Manages player connected to server.
class PlayerManager {

  /// Counter of connected players.
  static int PLAYER_COUNT = 0;

  /// Players list.
  Map<PlayerEntity, WebSocket> players;

  /// Default constructor.
  PlayerManager() {
    /// Initialize list of players.
    players = new Map<PlayerEntity, WebSocket>();
  }

  /// Player connected handler.
  void connectPlayer(WebSocket socket) {
    print("player connected");
  }

  void playerMessage(WebSocket socket, msg) {
    PlayerEntity msgPe = new PlayerEntity.fromJson(msg);
    print("new player message:");
    print(msgPe);
    if(msgPe.message == null)
      return;
    if(msgPe.message == "newPlayer") {
      // Add new player.
      players[msgPe] = socket;
    }
    else if(msgPe.message == "update") {
      // Find the player and update it's location.
      players.forEach((pe, ws) {
        if(pe.userName == msgPe.userName) {
          pe.xCoordinate = msgPe.xCoordinate;
        }
      });
    }
    // Broadcast new/updated player to others.
    broadcastPlayer(msgPe);
  }

  /// Broadcast given player entity to all other players.
  void broadcastPlayer(PlayerEntity playerPe) {
    String peJson = playerPe.toJson();
    players.forEach((pe, ws) {
      if(pe.userName != playerPe.userName) {
        print("broadcast: $peJson");
        ws.add(peJson);
      }
    });
  }

  /// Player disconnected handler.
  void disconnectPlayer(WebSocket socket) {
    players.forEach((pe, ws) {
      if(ws == socket) {
        pe.message = "leave";
        broadcastPlayer(pe);
        return;
      }
    });
  }
}

/// Server class
/// Listens for websocket requests.
class Server {

  /// Address on which server is listening.
  InternetAddress address;
  /// Port on which server is listening.
  int port;
  /// PlayerManager object, manages players connected to server.
  PlayerManager playerManager;

  /// Server constructor.
  ///
  /// @param address Address on which server is listening [Default = 0.0.0.0].
  /// @port Port on which server is listening [Default = 9999].
  Server([this.address = "0.0.0.0", port = 9999]) {
    // Initialize player manager.
    playerManager = new PlayerManager();

    // Bind server to given (or default) address and port.
    HttpServer.bind(address, port).then((HttpServer server) {
      // Listen for requests.
      server.listen((HttpRequest req) {
        // Check if request is upgrade request, if it is,
        //  upgrade it and then call handler.
        if (WebSocketTransformer.isUpgradeRequest(req))
          WebSocketTransformer.upgrade(req).then(handleWebSocket);
        // If it"s standard request, just serve it.
        else
          serveRequest(req);
      });
    });
    // Print "server is listening" message.
    print("HttpServer listening on $address:$port...");
  }

  /// handler for WebSocket request.
  void handleWebSocket(WebSocket socket) {
    // Add new connected player.
    playerManager.connectPlayer(socket);
    socket.listen(
      (msg) => playerManager.playerMessage(socket, msg),      // Client connected.
      onDone: () => playerManager.disconnectPlayer(socket)    // Client disconnected.
      );
  }

  /// handler for non-upgrade (standard) request.
  void serveRequest(HttpRequest req) {
    // End response with FORBIDDEN status, server accepts socket requests only.
    req.response.statusCode = HttpStatus.FORBIDDEN;
    req.response.reasonPhrase = "WebSocket connections only";
    req.response.close();
  }

}

/// Main method.
void main() {
  // Start a new server on default address and port (0.0.0.0:8080).
  new Server();
}


