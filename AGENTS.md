# AGENTS.md

Compact guidance for AI agents working in this repository.

## Project

- Murdokus is a SwiftUI logic-puzzle game for macOS. App source lives in `Murdokus/`, unit tests in `MurdokusTests/`. Xcode project: `Murdokus.xcodeproj`. SwiftData persistence via `SavedGame` / `SavedGamesStore` and `SavedGameSnapshot` board data.
- Deployment target is macOS 27.0. Project settings currently declare Swift 5.0; the agent guide in `/Users/javirg/.claude/CLAUDE.md` requires Swift 6.2 / modern concurrency.

## Commands

- Build: `xcodebuild -project Murdokus.xcodeproj -scheme Murdokus build`
- Test: `xcodebuild -project Murdokus.xcodeproj -scheme Murdokus test`

## Architecture

- All game state lives in `GridEngine` (`@Observable`), injected via `@Environment(GridEngine.self)`.
- Views dispatch game actions through intents instead of mutating state directly: `UserIntent` → `GridEngine.handleIntent(_:)`; `TimerIntent` (`.start`, `.pause`, `.reset`) → `GridEngine.handleTimer(_:)`.
- Timer state: `elapsedTime`, `isTimerRunning`, `timerStartDate`, computed `elapsedSeconds`; reset via `resetGame` / `setupGameWith`.
- Game rules live in `GridEngine`: `canPlaceObject(atRow:col:newObject:)` enforces grid bounds, max 2 elements per cell, and suspect stacking (suspects may stack only on furniture with `canStackOnTop == true`).
- Placing a suspect triggers `applyXMarkRules`, which fills the suspect's row and column with X-marks.
- Placing the victim pauses the timer and sets `isSolved = true`.

## Swift & SwiftUI conventions

Follow the project agent guide at `/Users/javirg/.claude/CLAUDE.md` (distilled here for agents working in this repo):

- Swift 6.2+, modern concurrency (async/await). `@Observable` classes must be marked `@MainActor` unless the module has default actor isolation.
- Prefer `@Observable` + `@State` / `@Bindable` / `@Environment` over `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, or `@EnvironmentObject`.
- Use `foregroundStyle()`, `clipShape(.rect(cornerRadius:))`, the `Tab` API, and `navigationDestination(for:)` with `NavigationStack`.
- Avoid `onChange()` one-parameter variant; avoid `onTapGesture` (use `Button`); avoid `Task.sleep(nanoseconds:)` (use `Task.sleep(for:)`); avoid `DispatchQueue.main.async()`; avoid `UIScreen.main.bounds`; avoid `GeometryReader` when `containerRelativeFrame` / `visualEffect` would work; avoid `fontWeight` (use `bold()`); avoid hard-coded font sizes (use Dynamic Type); prefer `ImageRenderer` over `UIGraphicsImageRenderer`; avoid `AnyView`; do not break views into computed properties (extract structs); use `ForEach(x.enumerated(), id: \.element.id)` without converting to `Array`; use `.scrollIndicators(.hidden)`; use the newest ScrollView APIs.

- Prefer `replacing(_:with:)` over `replacingOccurrences(of:with:)`.
- Prefer `URL.documentsDirectory` and `appending(path:)` over string concatenation.
- Use `FormatStyle` instead of legacy `Formatter`; parse dates via `Date(inputString, strategy: .iso8601)`.
- User-input filtering must use `localizedStandardContains()`, not `contains()`.
- Avoid C-style number formatting (e.g. `String(format:)`); use `Text(abs(change), format: .number.precision(.fractionLength(2)))`.

SwiftData:

- If SwiftData is configured with CloudKit: no `@Attribute(.unique)`, model properties must have default values or be optional, and all relationships must be optional.

## Testing

- Unit tests use Swift Testing (`Testing` framework), not XCTest.

## Workflow

- Work phase by phase; wait for explicit user authorization before starting a new phase.
- Phase summaries and validation methods in Spanish; documentation and commits in English.
- Do not commit unless explicitly requested.

## Notes

- The timer UI (`TimerView`) is integrated above the board in `GridView`.