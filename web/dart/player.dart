// Imports
import 'dart:html';
import 'game.dart';
// --------------------

/// Player class, stores data about player's avatar.
class Player {

  // Reference to canvas element.
  Game ref;
  // Getter for game canvas rendering context.
  CanvasRenderingContext2D get ctx => ref.ctx;
  // Getter for game canvas width.
  int get cw => ref.w;
  // Getter for game canvas height.
  int get ch => ref.h;
  // Character position
  Point pos;
  // Character width and height
  int w,h;

  /// Initializes canvas, rendering context and fps rate.
  ///
  /// @param ref Reference to game object.
  Player(this.ref) {
    w = 64;
    h = 128;
  }

  void draw(int baseLine) {
    ctx.setFillColorRgb(255, 0, 0);
    ctx.fillRect(cw / 2, baseLine - h, w, h);
  }
}
