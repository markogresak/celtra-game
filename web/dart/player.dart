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
  bool draw(CanvasRenderingContext2D ctx, int baseLine) {
    // Update movement data.
    bool result = movement.update();
    // Update player entity.
    playerEntity.update(movement.px);
    // Set player paint color.
    /// ctx.setFillColorRgb(255, 0, 0);
    // Clear old player rect.
    ctx.clearRect(ref.xOrigin - (w * 2), ref.yOrigin - movement.opy - (h * 4), w * 4, h * 4);
    // Draw player on new position.
    /// ctx.fillRect(ref.xOrigin, ref.yOrigin - movement.py - h, w, h);

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

    ctx.drawImageScaled(playerCanvas, ref.xOrigin, ref.yOrigin - movement.py - h, w, h);

    ctx.setFillColorRgb(0, 0, 0);
    ctx.fillText(userName, ref.xOrigin, ref.yOrigin - movement.py - h + 16);

    return result;
  }
}
