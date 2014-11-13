import 'dart:html';
import 'dart:collection';


/// MovementKeyList
/// Extends List with storage for movement key(s) handler function.
class MovementKeyList<E> extends ListBase<E> {

  List innerList = new List();

  /// KeyDown event handler function.
  Function keyDownHandler;
  /// KeyUp event handler function.
  Function keyUpHandler;

  /// Default constructor, Initializes handler function and calls list constructor.
  MovementKeyList(this.keyDownHandler, this.keyUpHandler);

  // Length setter and getter.
  int get length => innerList.length;
  void set length(int length) =>innerList.length = length;

  // [] operator getter and setter.
  E operator [](int index) => innerList[index];
  void operator[]=(int index, E value) => innerList[index] = value;

  /// Add an element to list.
  void add(E value) => innerList.add(value);

  /// Add a list of elements to list.
  void addAll(Iterable<E> all) => innerList.addAll(all);
}


/// Movement
/// Stores data about player movement.
class Movement {

  // Min and max height constants.
  static const float CAP_VELOCITY_X = 10.0;
  static const float CAP_VELOCITY_Y = 15.0;
  static const float CAP_ACCELERATION_X = 5.0;
  static const float CAP_ACCELERATION_Y = 10.0;
  static const float ACCELERATION_GRAVITY = -9.8;

  /// Position data.
  Point pos;
  /// Velocity data.
  float vx, vy;
  /// Acceleration data.
  float ax, ay;

  /// Collection of keys used to move left.
  MovementKeyList<KeyCode> keysLeft;
  /// Collection of keys used to move right.
  MovementKeyList<KeyCode> keysRight;
  /// Collection of keys used to jump.
  MovementKeyList<KeyCode> keysJump;
  /// Collection of keys used to attack.
  MovementKeyList<KeyCode> keysAttack;
  /// Collection of all keys.
  List<MovementKeyList> allKeys;

  /// Default constructor, accepts optional argumets of velocity and/or acceleration.
  ///
  /// @param vx (optional) Velocity on x coordinate [default = 0].
  /// @param vy (optional) Velocity on y coordinate [default = 0].
  /// @param ax (optional) Acceleration on x coordinate [default = 0].
  /// @param ay (optional) Acceleration on y coordinate [default = 0].
  Movement([float this.vx = 0.0, float this.vy = 0.0, float this.ax = 0.0, float this.ay = ACCELERATION_GRAVITY]) {
    // Initialize keys lists.
    keysLeft = new MovementKeyList<KeyCode>(playerLeftBegin, playerLeftEnd);
    keysRight = new MovementKeyList<KeyCode>(playerRightBegin, playerRightEnd);
    keysJump = new MovementKeyList<KeyCode>(playerJumpBegin, playerJumpEnd);
    keysAttack = new MovementKeyList<KeyCode>(playerAttackBegin, playerAttackEnd);
    allKeys = new List<MovementKeyList>();

    // Add corresponding keys to list.
    keysLeft.addAll([KeyCode.LEFT, KeyCode.A]);
    keysRight.addAll([KeyCode.RIGHT, KeyCode.D]);
    keysJump.addAll([KeyCode.UP, KeyCode.W]);
    keysAttack.addAll([KeyCode.SPACE]);

    // Store all keys.
    allKeys.addAll([keysLeft, keysRight, keysJump, keysAttack]);

    // Add key event listeners.
    window.onKeyDown.listen(__checkKeyDown);
    window.onKeyUp.listen(__checkKeyUp);
  }

  /// Handler function for onKeyDown listener.
  void __checkKeyDown(KeyboardEvent e) {
    //
    allKeys.forEach((keyList) => keyList.forEach((key) {
      if(key == e.keyCode)
        return keyList.keyDownHandler();
    }));
  }

  /// Handler function for onKeyUp listener.
  void __checkKeyUp(KeyboardEvent e) {
    allKeys.forEach((keyList) => keyList.forEach((key) {
      if(key == e.keyCode)
        return keyList.keyUpHandler();
    }));
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
    val *= sign;
    // Return minimal of the two values, multiplied with sign to get back original sign.
    return min(val, cap) * sign;
  }

  /// Handler function, triggered when one of _keysLeft_ is pressed.
  void playerLeftBegin() {
    ax = __constrain(ax - ax, CAP_ACCELERATION_X);
    vx = __constrain(vx - ax, CAP_VELOCITY_X);
  }

  /// Handler function, triggered when one of _keysLeft_ is released.
  void playerLeftEnd() {
    ax = 0.0;
    vx = 0.0;
  }

  /// Handler function, triggered when one of _keysRight_ is pressed.
  void playerRightBegin() {
    ax = __constrain(ax + ax, CAP_ACCELERATION_X);
    vx = __constrain(vx + ax, CAP_VELOCITY_X);
  }

  /// Handler function, triggered when one of _keysRight_ is released.
  void playerRightEnd() {
    ax = 0.0;
    vx = 0.0;
  }

  /// Handler function, triggered when one of _keysJump_ is pressed.
  void playerJumpBegin() {
    ay = 20.0;
    vy = __constrain(vy + ay, CAP_VELOCITY_Y);
    ay = __constrain(ay + ACCELERATION_GRAVITY, CAP_ACCELERATION_Y);
  }

  /// Handler function, triggered when one of _keysJump_ is released.
  void playerJumpEnd() {
    ay = ACCELERATION_GRAVITY;
    vy = 0.0;
  }

  /// Handler function, triggered when one of _keysAttack_ is pressed.
  void playerAttackBegin() {
    print("begin attack");
  }

  /// Handler function, triggered when one of _keysAttack_ is released.
  void playerAttackEnd() {
    print("end attack");
  }

  /// Updates position and movement data.
  void update() {
    pos.x += vx.floor();
    pos.y += vy.floor();
  }
}

