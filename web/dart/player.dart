// Imports
import 'dart:html';
import 'game.dart';
import 'movement.dart';
// --------------------

/// Player class
/// Stores data about player's avatar.
class Player {

  /// Reference to game object.
  Game ref;
  /// Reference to player movement object.
  Movement movement;
  /// Getter for game canvas rendering context.
  CanvasRenderingContext2D get ctx => ref.ctx;
  /// Getter for game canvas width.
  int get cw => ref.w;
  /// Getter for game canvas height.
  int get ch => ref.h;
  /// Character width and height
  int w,h;

  /// Initializes canvas, rendering context and fps rate.
  ///
  /// @param ref Reference to game object.
  Player(this.ref) {
    w = 32;
    h = 64;
    movement = new Movement();
  }

  void draw(int baseLine) {
    ctx.setFillColorRgb(255, 0, 0);
    ctx.fillRect(cw / 2, baseLine - h, w, h);
  }
}
