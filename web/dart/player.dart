// Imports
import 'dart:html';
import 'game.dart';
import 'movement.dart';
import './shared/playerEntity.dart';
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
  /// Player name.
  String userName;
  /// Player entity.
  PlayerEntity playerEntity;
  /// Player image.
  ImageElement playerImg;
  /// Canvas where player image is rendered.
  CanvasElement playerCanvas;
  /// Player canvas rendering context.
  CanvasRenderingContext2D playerCtx;

  /// Initializes canvas, rendering context and fps rate.
  ///
  /// @param ref Reference to game object.
  Player(this.ref, String this.userName, ImageElement this.playerImg) {
    // Initialize width and height.
    w = 32;
    h = 64;
    // Initialize canvas and canvas context.
    playerCanvas = new CanvasElement(width: w, height: h);
    playerCtx = playerCanvas.context2D;
    // Initialize movement object.
    movement = new Movement(ref);
    playerEntity = new PlayerEntity(movement.px, userName);
  }

  /// Draw the player on provided canvas context.
  ///
  /// @param ctx Canvas context on which player is painted.
  /// @param baseLine Baseline (y = 0) of platform.
  void draw(CanvasRenderingContext2D ctx, int baseLine, int px, int py, int offset) {
    playerCtx.clearRect(0, 0, w, h);
    /// playerCtx.drawImage(playerImg, ref.xOrigin, ref.yOrigin - movement.py - h);

    /// int dir = movement.vx < 0 ? -1 : 1;
    /// print(dir);
    /// if(movement.vx < 0) {
    ///   print("move left");
    ///   playerCtx.translate(w, 0);
    ///   playerCtx.scale(-1, 1);
    /// }
    /// else {
    ///   print("move right");
    /// }

    playerCtx.drawImage(playerImg, 0, 0);

    /// ctx.drawImageScaled(playerCanvas, ref.xOrigin + offset, ref.yOrigin - py - h, w, h);
    ctx.drawImageScaled(playerCanvas, ref.xOrigin + offset, baseLine - py - h, w, h);

    // Draw player name.
    ctx.setFillColorRgb(0, 0, 0);
    ctx.fillText(userName, ref.xOrigin + offset, ref.yOrigin - py - h + 16);

    // Update old movement data.
    movement.opx = px;
    movement.opy = py;

    /// return result;
  }
}
