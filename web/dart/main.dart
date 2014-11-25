// Import dart html lib and game class
import 'dart:html';
import 'game.dart';
import 'serverConnect.dart';
// --------------------

/// Upper FPS rate limit - 60 fps is recommended.
const FPS = 60;

// Main function, the entry point of game.
void main() {
  // Get user login form.
  final form = querySelector("#form-login");
  // Set form submit event listener.
  form.onSubmit.listen((Event e) {
    // Prevent form from sending.
    e.preventDefault();
    // Get username element.
    Element usernameEl = querySelector("#username");
    // Return if username element wasn't found.
    if(usernameEl == null)
      return false;
    // Get value from username element.
    String username = usernameEl.value;
    // Return if username element was empty.
    if(username.trim().length == 0)
      return false;

    try {
      // Hide login form.
      querySelector(".login-container").style.display = "none";
      // Show game canvas container.
      querySelector(".container").style.display = "block";
      // Show attack button (shown on mobile only).
      querySelector(".mobile #attack").style.display = "block";
    } catch (ex) {}

    // Start game with entered username.
    startGame(username);
    return false;
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
