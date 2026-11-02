# AGENTS.md

## Project

Murdokus is a SwiftUI puzzle game (macOS). App source lives in `Murdokus/`, unit tests in `MurdokusTests/`. Xcode project: `Murdokus.xcodeproj`.

## Commands

- Build: `xcodebuild -project Murdokus.xcodeproj -scheme Murdokus build`
- Test: `xcodebuild -project Murdokus.xcodeproj -scheme Murdokus test`

## Architecture notes

- All game state lives in `GridEngine` (`@Observable`), injected via `@Environment(GridEngine.self)`.
- Views dispatch game actions through intents instead of mutating state directly:
  - `UserIntent` → `GridEngine.handleIntent(_:)`
  - `TimerIntent` (`.start`, `.pause`, `.reset`) → `GridEngine.handleTimer(_:)`
- Timer state: `elapsedTime`, `isTimerRunning`, `timerStartDate`, computed `elapsedSeconds`; reset via `resetGame` / `setupGameWith`.

## Notes

- The timer UI (`TimerView`) is integrated above the board in `GridView`.
