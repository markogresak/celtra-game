// Imports
import 'dart:html';
import 'dart:math';
import 'player.dart';
import 'platform.dart';
// --------------------

/// Main game class, doing all the "heavy lifting".
class Game {

  // Reference to canvas element
  CanvasElement gameCanvas;
  // Canvas rendering context
  CanvasRenderingContext2D ctx;
  // Getter for game canvas width
  int get w => gameCanvas.width;
  // Getter for game canvas height
  int get h => gameCanvas.height;
  // Draw interval, in milliseconds
  double interval;
  // Current time, in milliseconds
  int now;
  // Last time draw was called, in milliseconds
  int last;
  // Player object
  Player player;
  // Map rendering object
  Platform platform;

  /// Initializes canvas, rendering context and fps rate.
  ///
  /// @param gameCanvas Canvas on which game will be displayed.
  /// @param fps Rate of Frames Per Second.
  Game(CanvasElement this.gameCanvas, int fps) {
    // Set rendering context.
    this.ctx = gameCanvas.context2D;
    // Calculate interval based on fps.
    this.interval = 1000 / fps;
    // Initialize new character object
    this.player = new Player(this);
    // Initialize map object
    this.platform = new Platform(player, "game");
  }

  /// Runs the game.
  void run() {
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
    // Calculate baseline of canvas (it can change if canvas is resized).
    int baseLine = (h * 0.90).floor();
    // Draw the platform.
    platform.draw(ctx, baseLine);
    // Draw the player.
    player.draw(ctx, baseLine);
  }
}
