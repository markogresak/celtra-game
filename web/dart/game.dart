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
    // Initialize other players list.
    players = new List<Player>();
    // Get player image.
    playerImg = new ImageElement(src: "../img/player.png", width: 32, height: 64);
    // Initialize new character object.
    this.player = new Player(this, username, playerImg);
    // Initialize platform object.
    this.platform = new Platform(player, "Test Game");
    // Initialize connection
    this.connection = new Connection(connectionOpen, connectionMessage);
  }

  /// Connected to server event handler.
  void connectionOpen(Event e) {
    // Run the game.
    run();
  }

  /// Server sent an message event handler.
  void connectionMessage(MessageEvent e) {
    try {
      // Parse data as playerEntity.
      PlayerEntity msgPe = new PlayerEntity.fromJson(e.data);
      print("new player message:");
      print(msgPe);
      // Failsafe if message is null.
      if(msgPe.message == null)
        return;
      // If new player conencted.
      if(msgPe.message == "newPlayer") {
        // Add new player.
        newPlayer(msgPe);
      }
      // If location update was recieved.
      else if (msgPe.message == "update") {
        // Find the player and update it's location.
        if(!updatePlayer(msgPe))
          newPlayer(msgPe);
        print("hegiht: ${player.movement.blockHeight(msgPe.xCoordinate)}");
      }
      // If other player attack was recieved.
      else if (msgPe.message == "attack") {
        // Call function to handle attack.
        handleAttack(msgPe);
      }
      // If player left.
      else if (msgPe.message == "leave") {
        // Call function to remove player from list.
        removePlayer(msgPe);
      }
    } catch(e) {}
  }

  /// Add new player from player entity.
  void newPlayer(PlayerEntity pe) {
    // Create new player object with recieved username.
    Player newPlayer = new Player(this, pe.userName, playerImg);
    // Set default location.
    newPlayer.movement.opx = newPlayer.movement.opy = 0;
    // Add new player to list.
    players.add(newPlayer);
  }

  /// Update other player location.
  bool updatePlayer(PlayerEntity pe) {
    // Loop through all players.
    for(int i = 0; i < players.length; i++) {
      // If player name matches, update the player and return true to mark success.
      if(players[i].userName == pe.userName) {
        players[i].movement.px = pe.xCoordinate;
        return true;
      }
    }
    // Return false to mark failed update.
    return false;
  }

  /// Handle other player attack.
  void handleAttack(PlayerEntity pe) {
    // Calculate distance between player and attack location.
    int distance = (pe.xCoordinate - player.movement.px).abs();
    print("distance: $distance < ${player.w * 2} => ${distance < player.w * 2}");
    // If distance is in range of player, register hit.
    if(distance < player.w * 1.25)
      player.wasHit();
  }

  /// Remove player who left.
  void removePlayer(PlayerEntity pe) {
    // Loop through all players.
    for(int i = 0; i < players.length; i++) {
      // If player name matches, remove the player and stop searching.
      if(players[i].userName == pe.userName) {
        players.removeAt(i);
        return;
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
    // Send new player location.
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

  /// Draws game contents on canvas.
  ///
  /// @param time Time passed since game was started.
  void __draw(double time) {
    // Check if player is dead.
    bool isDead = player.hitpoints.checkIfDead();
    // Clear whole canvas.
    ctx.clearRect(0, 0, w, h);
    // Update player.
    bool playerUpdated = player.movement.update() || isDead;
    // Draw player.
    player.draw(ctx, baseLine, player.movement.px, player.movement.py, 0, true);
    // Send updated player.
    if(playerUpdated)
      connection.sendPlayer(player.playerEntity);
    // Draw other players.
      players.forEach( (p) {
        p.draw(ctx, baseLine, p.movement.px, player.movement.blockHeight(p.movement.px) * 32, p.movement.px - player.movement.px, false);
      });
    // Draw the platform.
    platform.draw(ctx, baseLine, xOrigin - player.movement.px, playerUpdated, player.movement.px, player.movement.py);
  }
}
