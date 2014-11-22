import 'dart:html';
import 'dart:collection';
import 'movement.dart';
import 'platform.dart';

/// Controls
///
class Controls {

  // Reference to movement object.
  Movement movementRef;

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

  Controls(this.movementRef) {

    // Initialize keys lists.
    keysLeft = new MovementKeyList<KeyCode>(movementRef.playerLeftBegin, movementRef.playerMoveStop);
    keysRight = new MovementKeyList<KeyCode>(movementRef.playerRightBegin, movementRef.playerMoveStop);
    keysJump = new MovementKeyList<KeyCode>(movementRef.playerJumpBegin, movementRef.playerJumpEnd);
    keysAttack = new MovementKeyList<KeyCode>(movementRef.playerAttackBegin, movementRef.playerAttackEnd);
    allKeys = new List<MovementKeyList>();

    // Add corresponding keys to list.
    keysLeft.addAll([KeyCode.LEFT, KeyCode.A]);
    keysRight.addAll([KeyCode.RIGHT, KeyCode.D]);
    keysJump.addAll([KeyCode.UP, KeyCode.W]);
    keysAttack.addAll([KeyCode.SPACE]);

    // Store all keys.
    allKeys.addAll([keysLeft, keysRight, keysJump, keysAttack]);

    // Initialize keyboard events.
    __initKeyEvents();

        // Initialize touch events.
    __initTouchEvents();
  }

  void __initKeyEvents() {
    // Add key event listeners.
    window.onKeyDown.listen(__checkKeyDown);
    window.onKeyUp.listen(__checkKeyUp);
  }

  void __initTouchEvents() {
    document.onTouchStart.listen(__onTouchStart);
    document.onTouchEnd.listen(__onTouchEnd);
  }

  /// Handler function for onKeyDown listener.
  void __checkKeyDown(KeyboardEvent e) {
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

  /// Handler function for touch start event listener.
  void __onTouchStart(TouchEvent e) {
    // Prevent posible default action.
    e.preventDefault();

    // If there were touch events recorded.
    if (e.touches.length > 0) {
      // Get touch location.
      int touchLocation = e.touches[0].page.x;
      // Calculate screen half.
      int screenHalf = (movementRef.gameRef.w / 2).floor();
      // Determine player movement location.
      int movementDirection = (touchLocation - screenHalf).sign;
      // If player movement direction is DIRECTION_LEFT, move player to left.
      if(movementDirection == Platform.DIRECTION_LEFT)
        movementRef.playerLeftBegin();
      // If player movement direction is DIRECTION_RIGHT, move player to right.
      else if(movementDirection == Platform.DIRECTION_RIGHT)
        movementRef.playerRightBegin();
    }
  }

  /// Handler function for touch end event listener.
  void __onTouchEnd(TouchEvent e) {
    // Stop player movement.
    movementRef.playerMoveStop();
  }
}


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
