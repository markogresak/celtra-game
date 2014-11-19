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
    movement = new Movement(ref);
  }

  /// Draw the player on provided canvas context.
  ///
  /// @param ctx Canvas context on which player is painted.
  /// @param baseLine Baseline (y = 0) of platform.
  bool draw(CanvasRenderingContext2D ctx, int baseLine) {
    // Update movement data.
    bool result = movement.update();
    // Set player paint color.
    ctx.setFillColorRgb(255, 0, 0);
    // Clear old player rect.
    ctx.clearRect(ref.xOrigin, ref.yOrigin - movement.opy - h, w, h);
    // Draw player on new position.
    ctx.fillRect(ref.xOrigin, ref.yOrigin - movement.py - h, w, h);

    return result;
  }
}
