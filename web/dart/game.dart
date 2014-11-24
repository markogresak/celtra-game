// Imports
import 'dart:html';
import 'dart:math';
import 'player.dart';
import 'platform.dart';
import 'serverConnect.dart';
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
    PlayerEntity msgPe = new PlayerEntity.fromJson(e.data);
    print("new player message:");
    print(msgPe);
    if(msgPe.message == null)
      return;
    if(msgPe.message == "newPlayer") {
      // Add new player.
      Player newPlayer = new Player(this, msgPe.userName, playerImg);
      players.add(newPlayer);
    }
    else if (msgPe.message == "update") {
      // Find the player and update it's location.
      for(int i = 0; i < players.length; i++) {
        if(players[i].userName == msgPe.userName) {
          players[i].movement.px = msgPe.xCoordinate;
          break;
        }
      }
    }
    else if (msgPe.message == "leave") {
      for(int i = 0; i < players.length; i++) {
        if(players[i].userName == msgPe.userName) {
          players.removeAt(i);
          break;
        }
      }
    }
  }

  /// Runs the game.
  void run() {
    // Send new player.
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

  /// Draws game contents on canvas.
  ///
  /// @param time Time passed since game was started.
  void __draw(double time) {
    /// ctx.setFillColorRgb(126,192,238);
    ctx.setFillColorRgb(248, 248, 248);
    // Draw the player.
    bool playerUpdated = player.draw(ctx, baseLine);
    // Send updated player.
    connection.sendPlayer(player.playerEntity);
    // Draw other players.
    players.forEach((p) => p.draw(ctx, baseLine));
    // Draw the platform.
    platform.draw(ctx, baseLine, xOrigin - player.movement.px, playerUpdated);

  }
}
