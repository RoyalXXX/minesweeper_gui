# Minesweeper GUI: Inter-Process Communication in Godot

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Godot v4.6](https://img.shields.io/badge/Godot-v4.6-blue.svg)](https://godotengine.org/)

Minesweeper GUI is a simple yet illustrative project demonstrating how to build a game using the Godot 4 engine while delegating all game logic and computations to an external C++ console application.

This project serves as a clean example of separating the user interface from the core game logic. The Godot-based game handles only rendering, user interactions, and sending/receiving commands. All calculations—such as mine placement, tile revealing, win/loss conditions, etc.—are performed by a lightweight C++ backend, `engine.exe`.

![alt text](https://github.com/RoyalXXX/minesweeper_gui/blob/main/screenshot.png)

## Architecture
- **Frontend**: Developed in Godot 4 using GDScript. Handles:

  - GUI rendering

  - Input handling

  - Communication with the game engine (via standard input/output)

- **Backend**: A separate C++ console application (`engine.exe`) that runs in the background as a separate process. It:

  - Performs all game logic

  - Responds to commands from the GUI

  - Terminates when the game is closed

## Why This Approach?
**Performance**: Heavy computations are offloaded to a fast, compiled C++ engine.

**Modularity**: You can easily replace `engine.exe` with another backend (e.g., a Rust or Python engine) as long as it follows the same command protocol—without changing the Godot project.

**Educational Value**: Great example of how to integrate Godot with external processes and structure larger, decoupled systems.

## Engine
The `engine.exe` console application communicates with the Godot frontend through inter-process communication (IPC) using pipes. It processes a set of simple text-based commands, enabling the GUI to control the game logic without handling any calculations directly. 

Supported commands:

- `startGame` – Initializes a new game with a freshly generated minefield.

- `getBoardState` – Returns the current visible state of the game board (as seen by the player).

- `clickCell` – Attempts to reveal a specific cell (simulate a left-click).

- `setFlag` – Toggles a flag on a specific cell (simulate a right-click).

- `quit` – Terminates the engine process.

> [!TIP]
> You can use your own engine with different commands — to do this, you need to rename the five commands mentioned above in the `game.gd` file to your own.

> [!NOTE]
> The `engine.exe` used in this project is based on code from **BDOTimer**.
