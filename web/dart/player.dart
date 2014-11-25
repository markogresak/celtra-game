// Imports
import 'dart:html';
import 'dart:math';
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
  /// Hitpoints object.
  Hitpoints hitpoints;
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

    // Initialize player.
    initPlayer();
  }

  /// Player Initialization, called when game is started and upon death.
  void initPlayer() {
    // Initialize movement object.
    movement = new Movement(ref);
    // Initialize player entity.
    playerEntity = new PlayerEntity(movement.px, userName);
    // Send new player location.
    ref.connection.sendPlayer(playerEntity);
    // Initialize hitpoints.
    hitpoints = new Hitpoints(onDeath);
  }

  /// Halder function, gets called when player dies.
  void onDeath() {
    // Re-initialize player (reset healh, go to starting position).
    initPlayer();
  }

  /// Halder function, gets called when player gets hit.
  void wasHit() {
    // Get hit for randomly generated amount.
    hitpoints.hit(Hitpoints.GenerateRandomHit());
  }

  /// Draw the player on provided canvas context.
  ///
  /// @param ctx Canvas context on which player is painted.
  /// @param baseLine Baseline (y = 0) of platform.
  void draw(CanvasRenderingContext2D ctx, int baseLine, int px, int py, int offset, bool drawHp) {

    // Clear player canvas context.
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

    // (Re)draw player image.
    playerCtx.drawImage(playerImg, 0, 0);

    // Draw player image on canvas.
    ctx.drawImageScaled(playerCanvas, ref.xOrigin + offset, baseLine - py - h, w, h);

    // Draw player name.
    ctx.setFillColorRgb(0, 0, 0);
    ctx.fillText(userName, ref.xOrigin + offset, ref.yOrigin - py - h + 16);

    // Draw hitpoints.
    if(drawHp)
      hitpoints.draw(ctx, cw);

    // Update old movement data.
    movement.opx = px;
    movement.opy = py;

    /// return result;
  }
}

class Hitpoints {

  /// Starting hitpoints constant.
  static const int STARTING_HITPOINTS = 100;

  /// Minimum hit constant.
  static const int MIN_HIT = 0;
  /// Maximum hit constant.
  static const int MAX_HIT = 10;

  static int GenerateRandomHit() {
    Random r = new Random();
    return r.nextInt(MAX_HIT) + MIN_HIT;
  }

  /// Current hitpoints level.
  int hp;
  /// Death handler function.
  Function deathHandler;

  /// Default constructor, required death handler function.
  Hitpoints(this.deathHandler) {
    // Initialize hitpoints.
    hp = STARTING_HITPOINTS;
  }

  /// Heal by amout hitpoints.
  void heal(int amount) {
    // Constrain hitpoints to starting value.
    hp = min(hp + amount, STARTING_HITPOINTS);
  }

  /// Reduce hp bt amount hitpoints.
  void hit(int amount) {
    // Substract hitpoints.
    hp -= amount;
    // Check if player is dead.
    checkIfDead();
  }

  /// Checks if player is dead.
  void checkIfDead() {
    // Check if hp is at or below zero.
    if(hp <= 0)
      // Call death handler function.
      deathHandler();
  }

  /// Draw hitpoints bar.
  ///
  /// @param ctx Canvas rendering context.
  /// @param cw Width of canvas.
  void draw(CanvasRenderingContext2D ctx, int cw) {
    // Set fill color.
    ctx.setFillColorRgb(220, 20, 60);
    // Draw hitpoints at (10, 10), at most 1/2 of canvas wide.
    ctx.fillRect(10, 10, cw * .5 * (hp / STARTING_HITPOINTS), 20);
  }
}
