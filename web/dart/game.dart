// Imports
import 'dart:html';
import 'dart:math';
import 'character.dart';
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
  // Character object
  Character char;

  /// Initializes canvas, rendering context and fps rate.
  ///
  /// @param gameCanvas Canvas on which game will be displayed.
  /// @param fps Rate of Frames Per Second.
  Game(this.gameCanvas, fps) {
    // Set rendering context.
    this.ctx = gameCanvas.context2D;
    // Calculate interval based on fps.
    this.interval = 1000 / fps;
    // Initialize new character object
    this.char = new Character(this);
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

  void drawLine(x1, y1, x2, y2) {
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.stroke();
  }

  double tanDeg(num x) {
    return tan(x * PI/180);
  }

  void drawTriangle(num x1, num y1, num width, num alpha, num beta) {
    if(!((alpha >= 0 && alpha < 90 && beta == 90) || (alpha == 90 && beta >= 0 && beta < 90)))
      return;
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x1 + width, y1);


    num angle = alpha < 90 ? alpha : beta;

    num y2 = y1 - tanDeg(angle) * width;
    num x2 = alpha < 90 ? x1 + width : x1;

    ctx.lineTo(x2, y2);
    ctx.lineTo(x1, y1);
    ctx.fill();
  }

  /// Draws game contents on canvas.
  ///
  /// @param time Time passed since game was started.
  void __draw(double time) {
    // Clear whole canvas
    ctx.clearRect(0, 0, w, h);
    ctx.setFillColorRgb(156, 204, 84);
    int baseLine = (h * .9).floor();
//    ctx.fillRect(0, baseLine, w, h);
//    char.draw(baseLine);

    for(int i = 0; i < w; i += 32)
      drawLine(i, 0, i, h);

    for(int i = 0; i < h; i += 32)
      drawLine(0, i, w, i);

    Random r = new Random(1234);
    for(int i = 0; i < w; i += 32) {
      int height = (r.nextInt(10) + 1) * 32;
      ctx.fillRect(i, h - height, 32, height);
      int alpha = r.nextBool() ? r.nextInt(45) : 90;
      int beta = alpha == 90 ? r.nextInt(45) : 90;
      drawTriangle(i, h - height, 32, alpha, beta);
    }
  }
}
