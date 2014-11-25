import 'dart:convert' show JSON;

class PlayerEntity {

  int xCoordinate;
  String userName;
  String message;

  PlayerEntity(int this.xCoordinate, String this.userName);

  PlayerEntity.fromJson(var json) {
    try {
      Map data = JSON.decode(json);
      this.xCoordinate = data["xCoordinate"];
      this.userName = data["userName"];
      this.message = data["message"];
    } catch(e) {
      this.xCoordinate = 0;
      this.userName = null;
      this.message = null;
    }
  }

  Map toJson() {
    return {
      "xCoordinate": xCoordinate,
      "userName": userName,
      "message": message
    };
  }

  String getJson() {
    try {
      return JSON.encode(toJson());
    } catch(e) {
      print("ERROR while encoding PlayerEntity object:");
      print(e);
      return "{}";
    }
  }

  void update(int xCoordinate) {
    this.xCoordinate = xCoordinate;
    this.message = "update";
  }

  bool equals(other) {
    try {
      return userNameEquals(other.userName);
    } catch(e) {
      return false;
    }
  }

  bool userNameEquals(String userName) {
    try {
      return this.userName == userName;
    } catch(e) {
      return false;
    }
  }

  String toString() {
    return "$message: Player $userName, at location x = $xCoordinate";
  }
}
