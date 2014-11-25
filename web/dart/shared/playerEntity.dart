import 'dart:convert' show JSON;

/// PlayerEntity
/// Holds data which is transited to other players.
class PlayerEntity {

  /// X coordinate of player.
  int xCoordinate;
  /// Player's username.
  String userName;
  /// Message of packet.
  String message;

  /// Default constructor, requires x coordinate and username.
  PlayerEntity(int this.xCoordinate, String this.userName);

  /// Constructor to initialize PlayerEntity form given json object.
  PlayerEntity.fromJson(var json) {
    try {
      // Decode given json.
      Map data = JSON.decode(json);
      // Read x coordinate to object variable.
      this.xCoordinate = data["xCoordinate"];
      // Read username to object variable.
      this.userName = data["userName"];
      // Read message to object variable.
      this.message = data["message"];
    } catch(e) {
      // On exception, initialize with null values.
      this.xCoordinate = 0;
      this.userName = null;
      this.message = null;
    }
  }

  /// Convert this PlayerEntity to json object.
  Map toJson() {
    return {
      "xCoordinate": xCoordinate,
      "userName": userName,
      "message": message
    };
  }

  /// Convert this PlayerEntity to json string.
  String getJson() {
    try {
      // Try to encode toJson() object.
      return JSON.encode(toJson());
    } catch(e) {
      // On exception, return empty object string.
      print("ERROR while encoding PlayerEntity object:");
      print(e);
      return "{}";
    }
  }

  /// Update x coordinate.
  void update(int xCoordinate) {
    // Update xCoordinate value.
    this.xCoordinate = xCoordinate;
    // Set message to update.
    this.message = "update";
  }

  /// Check if this PlayerEntity equals to other.
  bool equals(other) {
    try {
      // Return username equality result.
      return userNameEquals(other.userName);
    } catch(e) {
      // Upon error, return false.
      return false;
    }
  }

  /// Check for username equality.
  bool userNameEquals(String userName) {
    try {
      // Check if this object's username equals other object username.
      return this.userName == userName;
    } catch(e) {
      // Upon error, return false.
      return false;
    }
  }

  /// Convert this object to string (for debug output).
  String toString() {
    return "$message: Player $userName, at location x = $xCoordinate";
  }
}
