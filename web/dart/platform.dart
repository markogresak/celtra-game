import 'dart:math';
import 'player.dart';
import 'block.dart';

/// Player class, stores data about game platform.
class Platform {

  // Min and max height constants.
  static const MIN_HEIGHT = 0;
  static const MAX_HEIGHT = 127;

  // Direction constants.
  static const DIRECTION_LEFT = -1;
  static const DIRECTION_BOTH = 0;
  static const DIRECTION_RIGHT = 1;

  /// Reference to player object.
  Player player;
  /// Id of platform (used for random seed).
  int platformId;
  /// Collection of all blocks on platform.
  Map blocks;
  /// Random block generator.
  BlockGenerator generator;

  /// Default constructor.
  ///
  /// @param player Reference to player object.
  /// @param mapName (optional) Name of current map - used for platformId => affects random seed.
  Platform(Player this.player, [String platformName = "platform"]) {
    // Set platformId from platformName hash.
    platformId = platformName.hashCode;
    // Initialize blocks collection and add origin block.
    blocks = new Map<int, Block>();
    blocks[0] = new Block(0, MIN_HEIGHT);
    // Initialize random generator and generate first 100 blocks in each direction.
    generator = new BlockGenerator(this);
    generatePlatform();
  }

  /// Find limit x coordinate of block in given direction.
  ///
  /// @param direction Direction of search (valid: DIRECTION_LEFT or DIRECTION_RIGHT).
  int __findLimit(int direction) {
    // Do not search if no blocks or only origin block is added.
    if(blocks.length <= 1)
      return 0;
    // Sort block keys
    var sortedKeys = blocks.keys.toList()..sort();
    // If looking for left limit, return first (lowest) key.
    if(direction == DIRECTION_LEFT)
      return sortedKeys.first;
    // If looking for right limit, return last (highest) key.
    else if(direction == DIRECTION_RIGHT)
      return sortedKeys.last;
    // Fallback value, if invalid parameter or something went wrong.
    return 0;
  }

  /// Find lowest x coordinate of block (search in left direction).
  int findLowestCoordinate() {
    return __findLimit(DIRECTION_LEFT);
  }

  /// Find highest x coordinate of block (search in right direction).
  int findHighestCoordinate() {
    return __findLimit(DIRECTION_RIGHT);
  }

  /// Randomly generate blocks on platform.
  ///
  /// @param blockAmount (optional) Amount of blocks to generate [default = 100].
  /// @param direction (optional) Direction in which blocks are generated [default = DIRECTION_BOTH].
  void generatePlatform([int blockAmount = 100, int direction = DIRECTION_BOTH]) {
    // If generating in right (or both) direction.
    if(direction == DIRECTION_RIGHT || direction == DIRECTION_BOTH) {
      // Find current right x coordinate limit.
      int startRight = findHighestCoordinate();
      // Generate _blockAmount_ blocks, starting at the block right to current.
      for(int i = startRight + 1; i <= startRight + blockAmount; i++)
        blocks[i] = generator.nextRight(blocks[i - 1]);
    }
    // If generating in left (or both) direction.
    if(direction == DIRECTION_LEFT || direction == DIRECTION_BOTH) {
      // Find current left x coordinate limit.
      int startLeft = findLowestCoordinate();
      // Generate _blockAmount_ blocks, starting at the block left to current.
      for(int i = startLeft; i > startLeft - blockAmount; i--)
        blocks[i] = generator.nextLeft(blocks[i + 1]);
    }
  }

  /// Draw the platform on provided canvas context.
  ///
  /// @param ctx Canvas context on which platform is painted.
  void draw(CanvasRenderingContext2D ctx) {
    // Calculate baseline of canvas (it can change if canvas is resized).
    int baseLine = (player.ch * 0.90).floor();
    // Call draw function of each block.
    blocks.forEach((k,v) => blocks[k].draw(ctx, player.ch, baseLine));
  }

}
