import 'dart:math';
import 'dart:html';
import 'player.dart';
import 'block.dart';

/// Platform class, stores data about game platform.
class Platform {

  // Min and max height constants.
  static const int MIN_HEIGHT = 0;
  static const int MAX_HEIGHT = 10;

  // Direction constants.
  static const int DIRECTION_LEFT = -1;
  static const int DIRECTION_BOTH = 0;
  static const int DIRECTION_RIGHT = 1;

  /// Reference to player object.
  Player player;
  /// Id of platform (used for random seed).
  int platformId;
  /// Collection of all blocks on platform.
  Map blocks;
  /// Random block generator.
  BlockGenerator generator;
  /// Store old block count, width and height.
  int blockCount, w, h;
  /// Canvas element for pre-painting blocks on platform.
  CanvasElement offCanvas;

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

  /// Get height at given x coordinate.
  ///
  /// @param x The x coordinate of player.
  int height(int x) {
    if(blocks[x] != null)
      return blocks[x].height;
    return 0;
  }

  /// Find limit x coordinate of block in given direction.
  ///
  /// @param direction Direction of search (valid: DIRECTION_LEFT or DIRECTION_RIGHT).
  /// @returns Limit x coordinate in given direction.
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
  ///
  /// @returns Lowest x coordinate.
  int findLowestCoordinate() {
    return __findLimit(DIRECTION_LEFT);
  }

  /// Find highest x coordinate of block (search in right direction).
  ///
  /// @returns Highest x coordinate.
  int findHighestCoordinate() {
    return __findLimit(DIRECTION_RIGHT);
  }

  /// Randomly generate blocks on platform.
  ///
  /// @param blockAmount (optional) Amount of blocks to generate [default = 100].
  /// @param direction (optional) Direction in which blocks are generated [default = DIRECTION_BOTH].
  void generatePlatform([int blockAmount = 100, int direction = DIRECTION_BOTH]) {
    List<int> generatedIndexes = new List<int>();
    // If generating in right (or both) direction.
    if(direction == DIRECTION_RIGHT || direction == DIRECTION_BOTH) {
      // Find current right x coordinate limit.
      int startRight = findHighestCoordinate();
      // Generate _blockAmount_ blocks, starting at the block right to current.
      for(int i = startRight + 1; i <= startRight + blockAmount; i++) {
        blocks[i] = generator.nextRight(blocks[i - 1]);
        generatedIndexes.add(i);
      }
    }
    // If generating in left (or both) direction.
    if(direction == DIRECTION_LEFT || direction == DIRECTION_BOTH) {
      // Find current left x coordinate limit.
      int startLeft = findLowestCoordinate();
      // Generate _blockAmount_ blocks, starting at the block left to current.
      for(int i = startLeft; i > startLeft - blockAmount; i--) {
        blocks[i] = generator.nextLeft(blocks[i + 1]);
        generatedIndexes.add(i);
      }
    }
    fillGaps(generatedIndexes);
  }

  /// Fill 1 block wide holes (fixes walk over glitch).
  ///
  /// @param indexList List of indexes to check.
  void fillGaps(List<int> indexList) {
    // Loop through all indexes.
    indexList.forEach((i) {
      // Save current height.
      int curHeight = blocks[i].height;
      // Check for:
      //  - first block next exists and
      //  - second block next exists and
      //  - current height is the same as second next block height and
      //  - first block next height is lower than current height.
      if(blocks[i + 1] != null && blocks[i + 2] != null && curHeight == blocks[i + 2].height && blocks[i + 1].height < curHeight)
        // If all above is true, set first block next height to same as current height.
        blocks[i + 1].height = curHeight;
    });
  }

  void checkExtendPlatform() {
    int px = player.movement.px;
    int playerDirection = px.sign;
    int limit = __findLimit(playerDirection);

    if((limit / 2) < px)
      generatePlatform(100, playerDirection);
  }

  /// Sets fill color to the given canvas context.
  ///
  /// @param ctx canvas rendering context.
  void __setBlockColor(CanvasRenderingContext2D ctx) {
    ctx.setFillColorRgb(156, 204, 84);
  }

  /// Check if platform or canvas has updated since last draw.
  ///
  /// @returns True if updated, false if not.
  bool hasUpdated() {
    // Compare amount of blocks with previously stored block count
    //  or canvas has resized since last draw.
    return blocks.length != blockCount || w != player.cw || h != player.ch;
  }

  /// Draw the platform on provided canvas context.
  ///
  /// @param ctx Canvas context on which platform is painted.
  /// @param baseLine Baseline (y = 0) of platform.
  void draw(CanvasRenderingContext2D ctx, int baseLine, int xOrigin, bool playerUpdated, int px, int py) {
    // Check if platform or canvas has updated.
    if(playerUpdated || hasUpdated()) {
      // Check if player is over 1/2 of platform in current direction, if true,
      //  generate more blocks in given direction.
      checkExtendPlatform();

      // Update canvas width and height.
      w = player.cw;
      h = player.ch;
      // Update block count.
      blockCount = blocks.length;

      // Clear original canvas.
      ctx.clearRect(0, 0, w, h);

      // Create new canvas element for pre-painting blocks on platform.
      if(offCanvas != null) {
        offCanvas.width = w;
        offCanvas.height = h;
      }
      else
        offCanvas = new CanvasElement(width: w, height: h);
      // Get offCanvas context.
      CanvasRenderingContext2D offCtx = offCanvas.context2D;
      // Set block color.
      __setBlockColor(offCtx);

      // Draw each block on created offCanvas element
      blocks.forEach((k,b) => b.draw(offCtx, h, baseLine, xOrigin));

      player.draw(ctx, baseLine, px, py, 0, true);
    }

    // Draw platform on offCanvas to provided (main) canvas.
    ctx.drawImageScaled(offCanvas, 0, 0, w, h);
  }

}
