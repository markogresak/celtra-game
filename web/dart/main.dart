// Import dart html lib and game class
import 'dart:html';
import 'game.dart';
import 'serverConnect.dart';
// --------------------

/// Upper FPS rate limit - 60 fps is recommended.
const FPS = 60;

// Main function, the entry point of game.
void main() {
  final form = querySelector("#form-login");
  form.onSubmit.listen((Event e) {
    e.preventDefault();
    String username = querySelector("#username").value;
    if(username.trim().length == 0)
      return false;

    querySelector(".login-container").style.display = "none";
    querySelector(".container").style.display = "block";
    startGame(username);
  });
}

void startGame(String username) {
  // Initialize canvas element, save it for further use.
  final CanvasElement gameCanvas = init();
  // Set resize event listener.
  window.addEventListener("resize", ((e) => resizeCanvas(gameCanvas)), false);

  // Run the game.
  new Game(gameCanvas, FPS, username);
}

/// Initializes main canvas element.
///
/// @returns Canvas element.
CanvasElement init() {
  // Select canvas DOM element.
  final CanvasElement gameCanvas = querySelector("#game");
  // Resize canvas to fill whole viewport.
  resizeCanvas(gameCanvas);
  // Make sure canvas is focused.
  gameCanvas.focus();
  // Return found canvas element.
  return gameCanvas;
}

/// Sets canvas size to take whole window.
///
/// @param canvas Canvas to be resized.
void resizeCanvas(CanvasElement canvas) {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}
