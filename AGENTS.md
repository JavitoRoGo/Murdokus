# AGENTS.md

## Project

Murdokus is a SwiftUI puzzle game (macOS). App source lives in `Murdokus/`, unit tests in `MurdokusTests/`. Xcode project: `Murdokus.xcodeproj`.

## Commands

- Build: `xcodebuild -project Murdokus.xcodeproj -scheme Murdokus build`
- Test: `xcodebuild -project Murdokus.xcodeproj -scheme Murdokus test`

## Architecture

- All game state lives in `GridEngine` (`@Observable`), injected via `@Environment(GridEngine.self)`.
- Views dispatch game actions through intents instead of mutating state directly:
  - `UserIntent` → `GridEngine.handleIntent(_:)`
  - `TimerIntent` (`.start`, `.pause`, `.reset`) → `GridEngine.handleTimer(_:)`
- Timer state: `elapsedTime`, `isTimerRunning`, `timerStartDate`, computed `elapsedSeconds`; reset via `resetGame` / `setupGameWith`.

## Conventions

- Unit tests use Swift Testing (`Testing` framework), not XCTest.
- Game rules live in `GridEngine`: `canPlaceObject(atRow:col:newObject:)` enforces grid bounds, max 2 elements per cell, and suspect stacking (suspects may stack only on furniture with `canStackOnTop == true`).
- Placing a suspect triggers `applyXMarkRules`, which fills the suspect's row and column with X-marks.
- Placing the victim pauses the timer and sets `isSolved = true`.

## Workflow

- Work phase by phase; wait for explicit user authorization before starting a new phase.
- Phase summaries and validation methods in Spanish; documentation and commits in English.
- Do not commit unless explicitly requested.

## Notes

- The timer UI (`TimerView`) is integrated above the board in `GridView`.
- The undo feature is in progress; the task list lives in `undoPlan.md` at the repo root.
