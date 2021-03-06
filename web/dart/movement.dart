import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'platform.dart';
import 'controls.dart';

/// Movement
/// Stores data about player movement.
class Movement {

  // Cap speed constants.
  static const float CAP_VELOCITY_WALK = 5.0;
  static const float CAP_VELOCITY_Y = 15.0;
  static const float CAP_VELOCITY_RUN = 7.5;
  // Acceleration constants.
  static const float CAP_ACCELERATION_X = 2.0;
  static const float CAP_ACCELERATION_Y = 10.0;
  static const float ACCELERATION_WALK = .5;
  static const float ACCELERATION_JUMP = 20.0;
  static const float ACCELERATION_GRAVITY = -5.0;
  // Jump delay constant (in milliseconds).
  static const int JUMP_DELAY = 300;

  /// Position data.
  int px, py;
  /// Velocity data.
  float vx, vy;
  /// Acceleration data.
  float ax, ay;
  /// Old position data.
  int opx, opy;
  /// Jump and attack state.
  bool isJumping, isAttacking;
  /// Controls object
  Controls controls;

  /// Reference to platform object.
  Game gameRef;

  /// Default constructor.
  Movement(this.gameRef) {
    // Initialize controls object.
    controls = new Controls(this);
    resetMovement();
  }

  void resetMovement() {
    // Initialize player old and curent locations.
    opx = px = 0;
    opx = py = 0;
    // Initialize player velocity data.
    vx = 0.0;
    vy = 0.0;
    // Initialize player acceleration data.
    ax = 0.0;
    ay = ACCELERATION_GRAVITY;
    // Initialize player jumping state.
    isJumping = false;
    isAttacking = false;
  }

  /// Returns _val_ constrained to _cap_ (works for positive and negative values).
  ///
  /// @param val Value which is being constrained.
  /// @param cap Maximum possible value for _val_ (absolute).
  /// @returns Minimal (absolute) value of _val_ and _cap_.
  float __constrain(float val, float cap) {
    // Store sign of val.
    float sign = val.sign;
    // Multiply val by it's sign (to get absolute value).
    float _val = val * sign;
    // Return minimal of the two values, multiplied with sign to get back original sign.
    return min(_val, cap) * sign;
  }

  /// Handler function, triggered when one of _keysLeft_ is pressed.
  void playerLeftBegin() {
    ax = __constrain(ax - ACCELERATION_WALK, CAP_ACCELERATION_X);
  }
  /// Handler function, triggered when one of _keysRight_ is pressed.
  void playerRightBegin() {
    ax = __constrain(ax + ACCELERATION_WALK, CAP_ACCELERATION_X);
  }

  /// Handler function, triggered when one of player movement keys is released.
  void playerMoveStop() {
    ax = 0.0;
    vx = 0.0;
  }

  /// Handler function, triggered when one of _keysJump_ is pressed.
  void playerJumpBegin() {
    /// if(!isJumping) {
    ///   ay = ACCELERATION_JUMP;
    ///   isJumping = true;
    ///   new Timer(const Duration(milliseconds: JUMP_DELAY), () => isJumping = false);
    /// }
  }

  /// Handler function, triggered when one of _keysJump_ is released.
  void playerJumpEnd() {
  }

  /// Handler function, triggered when one of _keysAttack_ is pressed.
  void playerAttackBegin([bool spaceKey = false]) {
    if(!isAttacking || !spaceKey) {
      isAttacking = true;
      gameRef.attackNearbyPlayers();
    }
  }

  /// Handler function, triggered when one of _keysAttack_ is released.
  void playerAttackEnd() {
    isAttacking = false;
  }

  /// Get block height on given x coordinate.
  ///
  /// @param x The x coordinate of player.
  /// @returns The x coordinate of block (~player.x / 32).
  int blockHeight(int x) {
    // Get approximate location of the block.
    float block = x / gameRef.player.w;
    // Calculate left and right edges of the block on which player is standing on.
    int leftEdge = gameRef.platform.height(block.floor());
    int rightEdge = gameRef.platform.height(block.ceil());
    // Return maximum of the two edges (higher edge).
    return max(leftEdge, rightEdge);
  }

  /// Updates position and movement data.
  ///
  /// @returns True if update was successful, false otherwise.
  bool update() {
    // Store prevous player position data.
    opx = px;
    opy = py;
    // Calculate velocity on x axis, constrained to CAP_VELOCITY_WALK.
    vx = __constrain(vx + ax, CAP_VELOCITY_WALK);
    // Calculate velocity on y axis, constrained to CAP_VELOCITY_Y.
    vy = __constrain(vy + ay, CAP_VELOCITY_Y);
    // Calculate acceleration on y axis, reduce it by value of gravity constant or
    //  set it to the value of ACCELERATION_GRAVITY (gravity constant).
    ay = ay > ACCELERATION_GRAVITY ? ay + ACCELERATION_GRAVITY : ACCELERATION_GRAVITY;
    // Add current velocity on x axis to player's x coordinate.
    px += vx.floor();
    // Add greater value of velocity on y axis added to player's y coordinate and
    //  height of block player is currently standing on. This is used to
    //  prevent player getting stuck in ground.
    py = max(py + vy, blockHeight(px) * gameRef.player.w).floor();
    // Return whether player position has updated or not.

    // Update player entity.
    gameRef.player.playerEntity.update(px);
    return opx != px || opy != py;
  }
}

