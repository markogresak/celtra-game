import 'dart:math';
import 'dart:html';
import 'platform.dart';

/// Block class, stores data of each block on platform.
class Block {
  /// The x coordinate on map.
  int x;
  /// Height of current block (y coordinate).
  int height;

  /// Default Block constructor.
  ///
  /// @param x The x coordinate of block.
  /// @param height Height of block.
  Block(this.x, this.height);


  /// Draw block on provided canvas context.
  ///
  /// @param ctx Canvas context on which block is painted.
  /// @canvasHeight Height of game canvas.
  /// @baseLine Baseline, or minimum height of block.
  void draw(CanvasRenderingContext2D ctx, int canvasHeight, int baseLine) {
    int h = height * 32;
    ctx.fillRect(x * 32, baseLine - h, 32, h + (canvasHeight - baseLine));
  }
}

/// Block object generator
class BlockGenerator {

  /// Reference to platform object.
  Platform platformRef;

  /// Default constructors, sets reference to platform.
  ///
  /// @param platformRef Reference to platform object.
  BlockGenerator(this.platformRef);

  /// Calculate height of next block.
  ///
  /// @param x The x coordinate of block for which height is calculated.
  /// @param currentHeight Height of current block (next is in range current ± 1).
  /// @returns Height of next block, constrained to platform MIN_HEIGHT and MAX_HEIGHT.
  int __nextHeight(int x, int currentHeight) {
    // Initialize new random generator with seed of platformId + x coordinate.
    Random r = new Random(platformRef.platformId + x);
    // Generate next height.
    int newHeight = currentHeight + r.nextInt(3) - 1;
    // Constrain generated height to MIN_HEIGHT and MAX_HEIGHT.
    return min(max(newHeight, Platform.MIN_HEIGHT), Platform.MAX_HEIGHT);
  }

  /// Generate next block.
  ///
  /// @param cur Current block on platform.
  /// @param direction Relative direction of next block.
  /// @returns New Block object in _direction_ relative to curent.
  Block __next(Block cur, int direction) {
    return new Block(cur.x + direction, __nextHeight(cur.x + direction, cur.height));
  }

  /// Generate next block to the left.
  ///
  /// @param current Current block on platform.
  /// @returns New Block object left to current.
  Block nextLeft(Block current) {
    return __next(current, Platform.DIRECTION_LEFT);
  }

  /// Generate next block to the right.
  ///
  /// @param current Current block on platform.
  /// @returns New Block object right to current.
  Block nextRight(Block current) {
    return __next(current, Platform.DIRECTION_RIGHT);
  }
}
