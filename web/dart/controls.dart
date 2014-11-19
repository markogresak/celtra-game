import 'dart:html';
import 'dart:collection';
import 'movement.dart';


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
  }

  void __initKeyEvents() {
    // Add key event listeners.
    window.onKeyDown.listen(__checkKeyDown);
    window.onKeyUp.listen(__checkKeyUp);
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
