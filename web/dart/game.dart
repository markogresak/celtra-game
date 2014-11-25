// Imports
import 'dart:html';
import 'dart:math';
import 'player.dart';
import 'platform.dart';
import 'serverConnect.dart';
import './shared/playerEntity.dart';
// --------------------

/// Main game class
/// Doing all the "heavy lifting".
class Game {

  /// Reference to canvas element.
  CanvasElement gameCanvas;
  /// Canvas rendering context.
  CanvasRenderingContext2D ctx;
  /// Getter for game canvas width.
  int get w => gameCanvas.width;
  /// Getter for game canvas height.
  int get h => gameCanvas.height;
  /// Calculate baseline of canvas (it can change if canvas is resized).
  int get baseLine => (h * 0.90).floor();
  /// Origin of x coordinate (x = 0).
  int get xOrigin => (w / 2).floor();
  /// Origin of y coordinate (y = 0).
  int get yOrigin => baseLine;
  /// Draw interval, in milliseconds.
  double interval;
  /// Current time, in milliseconds.
  int now;
  /// Last time draw was called, in milliseconds.
  int last;
  /// Player object.
  Player player;
  /// Map rendering object.
  Platform platform;
  /// Player img element.
  ImageElement playerImg;
  /// List of all other players.
  List<Player> players;
  /// Connection to server.
  Connection connection;

  /// Initializes canvas, rendering context and fps rate.
  ///
  /// @param gameCanvas Canvas on which game will be displayed.
  /// @param fps Rate of Frames Per Second.
  Game(CanvasElement this.gameCanvas, int fps, String username) {
    print("start game: $username");
    // Set rendering context.
    this.ctx = gameCanvas.context2D;
    // Calculate interval based on fps.
    this.interval = 1000 / fps;
    // Get player image.
    playerImg = new ImageElement(src: "../img/player.png", width: 32, height: 64);
    // Initialize new character object.
    this.player = new Player(this, username, playerImg);
    // Initialize platform object.
    this.platform = new Platform(player, "Test Game");
    // Initialize other players list.
    players = new List<Player>();
    // Initialize connection
    connection = new Connection(connectionOpen, connectionMessage);
  }

  /// Connected to server event handler.
  void connectionOpen(Event e) {
    run();
  }

  /// Server sent an message event handler.
  void connectionMessage(MessageEvent e) {
    try {
      PlayerEntity msgPe = new PlayerEntity.fromJson(e.data);
      print("new player message:");
      print(msgPe);
      if(msgPe.message == null)
        return;
      if(msgPe.message == "newPlayer") {
        // Add new player.
        newPlayer(msgPe);
      }
      else if (msgPe.message == "update") {
        // Find the player and update it's location.
        if(!updatePlayer(msgPe))
          newPlayer(msgPe);
        print("hegiht: ${player.movement.blockHeight(msgPe.xCoordinate)}");
      }
      else if (msgPe.message == "leave") {
        removePlayer(msgPe);
      }
    } catch(e) {}
  }

  void newPlayer(PlayerEntity pe) {
    Player newPlayer = new Player(this, pe.userName, playerImg);
    newPlayer.movement.opx = 0;
    newPlayer.movement.opy = 0;
    players.add(newPlayer);
  }

  bool updatePlayer(PlayerEntity pe) {
    bool found = false;
    for(int i = 0; i < players.length; i++) {
      if(players[i].userName == pe.userName) {
        players[i].movement.px = pe.xCoordinate;
        found = true;
        break;
      }
    }
    return found;
  }

  void handleAttack(PlayerEntity pe) {

  }

  void removePlayer(PlayerEntity pe) {
    for(int i = 0; i < players.length; i++) {
      if(players[i].userName == pe.userName) {
        players.removeAt(i);
        break;
      }
    }
  }

  /// Send attack message.
  void attackNearbyPlayers() {
    // Create new PlayerEntity with current player location and player username.
    PlayerEntity attackPe = new PlayerEntity(player.movement.px, player.userName);
    // Mark message as attack.
    attackPe.message = "attack";
    // Send message to server.
    connection.sendPlayer(attackPe);
  }

  /// Runs the game.
  void run() {
    // Send new player.
    player.playerEntity.message = "newPlayer";
    connection.sendPlayer(player.playerEntity);
    // Set last time to 0 - draw was never called.
    last = 0;
    // Request animation frame for game loop.
    window.requestAnimationFrame(__gameloop);
  }

  /// Game loop, responsible for all calculations and updates.
  /// This function should be called using requestAnimationFrame.
  void __gameloop(double time) {

    // Request next animation frame.
    window.requestAnimationFrame(__gameloop);

    // Update current time.
    now = new DateTime.now().millisecondsSinceEpoch;
    // Calculate delta time between now and last time.
    int delta = now - last;

    // If delta is greater than interval, draw next frame.
    if(delta > interval) {
      // Update last time.
      last = now - (delta % interval).floor();
      // Draw next frame.
      __draw(time);
    }
  }

  int xOriignDistance(int x) {
    return
  }

  /// Draws game contents on canvas.
  ///
  /// @param time Time passed since game was started.
  void __draw(double time) {
    // Draw the player.
    ctx.clearRect(0, 0, w, h);
    bool playerUpdated = player.movement.update();
    player.draw(ctx, baseLine, player.movement.px, player.movement.py, 0);
    // Send updated player.
    if(playerUpdated)
      connection.sendPlayer(player.playerEntity);
    // Draw other players.
      players.forEach( (p) {
        p.draw(ctx, baseLine, p.movement.px, player.movement.blockHeight(p.movement.px) * 32, p.movement.px - player.movement.px);
      });
    // Draw the platform.
    platform.draw(ctx, baseLine, xOrigin - player.movement.px, playerUpdated, player.movement.px, player.movement.py);
  }
}
