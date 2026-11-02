//
//  GridEngine.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

/// The central engine responsible for managing the game state, grid logic, and timer for Murdokus.
///
/// `GridEngine` acts as the single source of truth for the game board, handling the placement
/// of suspects and objects, applying game rules (such as X-marks), and tracking the time elapsed.
/// It is designed to be injected into the environment and observed by SwiftUI views.
@Observable
final class GridEngine {
	/// The number of rows in the game grid.
	var rows: Int = 0
	/// The number of columns in the game grid.
	var columns: Int = 0
	/// A 2D array representing the grid cells and the objects contained within them.
	var cells: [[Cell]] = []
	/// The list of suspects involved in the current game session.
	var suspects: [MurdokuObject] = []
	/// The object currently being dragged across the grid, if any.
	var draggingObject: MurdokuObject? = nil
	/// The set of available colors used to paint the rooms in the grid.
	var roomColors: [Color] = []
	/// Controls whether the suspect list is visible in the user interface.
	var showingSuspects = false
	
	/// A boolean indicating whether all suspects have been placed on the grid.
	var allSuspectsPlaced: Bool {
		suspects.allSatisfy { $0.isPlaced ?? false }
	}
	
	/// The current color selected for painting cells.
	var activePaintColor: Color? = nil
	
	/// Total time elapsed in seconds, excluding the current active timer session.
	var elapsedTime: TimeInterval = 0
	/// Indicates whether the game timer is currently counting up.
	var isTimerRunning = false
	/// The timestamp when the current timer session started.
	var timerStartDate: Date?
	
	/// A static list of all available game objects derived from `MurdokuElement`.
	let objects: [MurdokuObject] = {
		MurdokuElement.elements.map {
			MurdokuObject(
				name: $0.rawValue,
				element: $0
			)
		}
	}()
	
	/// Represents a user-driven action that modifies the game state.
	enum UserIntent {
		/// Moves an object to a specific grid coordinate.
		case move(package: MurdokuTransferPackage, destinationRow: Int, destinationCol: Int)
		/// Removes a specific object from the grid.
		case delete(package: MurdokuTransferPackage)
		/// Changes the background color of a specific cell.
		case changeColor(color: Color, row: Int, col: Int)
	}
	
	/// Represents an action that modifies the state of the game timer.
	enum TimerIntent {
		/// Starts or resumes the timer.
		case start
		/// Pauses the timer and saves the current elapsed time.
		case pause
		/// Resets the timer to zero.
		case reset
	}

	/// Initializes a new game session with the specified grid dimensions and complexity.
	///
	/// - Parameters:
	///   - rows: The number of rows for the grid.
	///   - columns: The number of columns for the grid.
	///   - suspectsNumber: The number of suspects to generate.
	///   - colors: The number of available room colors to provide.
	func setupGameWith(rows: Int, columns: Int, suspectsNumber: Int, colors: Int) {
		resetTimer()
		self.rows = rows
		self.columns = columns
		generateGridAndColors(num: colors)
		generateSuspects(num: suspectsNumber)
	}

	/// Generates the game grid and selects the palette of room colors.
	///
	/// - Parameter num: The number of distinct colors to provide for the rooms.
	private func generateGridAndColors(num: Int) {
		guard rows > 0 && columns > 0 else { return }
		var newCells: [[Cell]] = []
		
		for _ in 0..<rows {
			var row: [Cell] = []
			for _ in 0..<columns {
				row.append(Cell(elements: [], color: .secondary.opacity(0.2)))
			}
			newCells.append(row)
		}
		self.cells = newCells
		
		let colors: [Color] = [.red, .blue, .yellow, .green, .orange, .purple, .brown, .pink, .mint, .indigo]
		self.roomColors = colors.prefix(upTo: num).map { $0.opacity(0.3) }
	}
	
	/// Generates the list of suspects for the current game session.
	///
	/// - Parameter num: The number of suspects to create.
	private func generateSuspects(num: Int) {
		let names = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "W", "X", "Y", "Z"]
		guard num > 0 && num <= names.count else { return }
		var suspectsList: [MurdokuObject] = []
		
		for i in 0 ..< num {
			let suspect = MurdokuObject(name: "Sospechoso \(names[i])", element: .suspect, capitalLetter: names[i])
			suspectsList.append(suspect)
		}
		self.suspects = suspectsList
	}
	
	/// Processes a user intent to update the game state.
	///
	/// - Parameter intent: The `UserIntent` to be handled.
	/// - Note: Move actions are wrapped in a spring animation for smoother UI transitions.
	func handleIntent(_ intent: UserIntent) {
		switch intent {
		case .move(let package, let destRow, let destCol):
			if canPlaceObject(atRow: destRow, col: destCol, newObject: package.object) {
				withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
					performMove(package: package, toRow: destRow, col: destCol)
				}
			}
			self.draggingObject = nil
		case .delete(let package):
			withAnimation(.spring()) {
				performDelete(package: package)
			}
			self.draggingObject = nil
		case .changeColor(let color, let row, let col):
			setRoomColor(color, atRow: row, col: col)
		}
	}
	
	/// Processes a timer intent to control the game's clock.
	///
	/// - Parameter intent: The `TimerIntent` to be handled.
	func handleTimer(_ intent: TimerIntent) {
		switch intent {
		case .start:
			startTimer()
		case .pause:
			pauseTimer()
		case .reset:
			resetTimer()
		}
	}
	
	/// Validates whether a given object can be placed in a specific grid cell.
	///
	/// - Parameters:
	///   - row: The target row index.
	///   - col: The target column index.
	///   - newObject: The object attempting to be placed.
	/// - Returns: `true` if the placement is valid according to game rules; otherwise, `false`.
	/// - Note: This checks for grid boundaries, cell occupancy (max 2 objects), and stacking rules for suspects.
	func canPlaceObject(atRow row: Int, col: Int, newObject: MurdokuObject) -> Bool {
		guard row >= 0 && row < rows && col >= 0 && col < columns else {
			return false
		}
		
		let targetCell = cells[row][col]
		
		if targetCell.elements.isEmpty {
			return true
		}
		
		if targetCell.elements.count >= 2 {
			return false
		}
		
		if let existingObject = targetCell.elements.last {
			if newObject.element == .suspect {
				return existingObject.element.canStackOnTop
			}
		}
		
		return false
	}
	
	/// Executes the movement of an object to a new cell, updating suspects and board state.
	///
	/// - Parameters:
	///   - package: The package containing the object and its origin.
	///   - toRow: The destination row.
	///   - col: The destination column.
	/// - Note: If a suspect is moved, X-mark rules are applied across the row and column.
	private func performMove(package: MurdokuTransferPackage, toRow: Int, col: Int) {
		guard toRow >= 0 && toRow < rows && col >= 0 && col < columns else { return }
		if package.object.element == .suspect {
			markSuspectAsPlaced(capitalLetter: package.object.capitalLetter)
			applyXMarkRules(forRow: toRow, col: col)
		}
		cells[toRow][col].elements.append(package.object)
		
		if package.sourceRow != -1 && (package.sourceRow != toRow || package.sourceCol != col) {
			clearCellAt(row: package.sourceRow, col: package.sourceCol, objectToRemove: package.object)
		}
		
		if package.object.element == .victim {
			pauseTimer()
		}
	}
	
	/// Updates the placement status of a suspect based on their identifier.
	///
	/// - Parameter capitalLetter: The identifying letter of the suspect.
	private func markSuspectAsPlaced(capitalLetter: String?) {
		suspects = suspects.map { suspect in
			guard suspect.capitalLetter == capitalLetter else { return suspect }
			var placedSuspect = suspect
			placedSuspect.isPlaced = true
			return placedSuspect
		}
	}
	
	/// Handles the deletion of an object from the grid.
	///
	/// - Parameter package: The package containing the object to be deleted and its origin.
	private func performDelete(package: MurdokuTransferPackage) {
		clearCellAt(row: package.sourceRow, col: package.sourceCol, objectToRemove: package.object)
	}
	
	/// Removes a specific object from a given grid cell.
	///
	/// - Parameters:
	///   - row: The row index.
	///   - col: The column index.
	///   - objectToRemove: The object to be removed by ID.
	private func clearCellAt(row: Int, col: Int, objectToRemove: MurdokuObject) {
		guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
		cells[row][col].elements.removeAll(where: { $0.id == objectToRemove.id })
	}
	
	/// Clears all elements from a specific grid cell.
	///
	/// - Parameters:
	///   - row: The row index.
	///   - col: The column index.
	private func clearCell(atRow row: Int, col: Int) {
		guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
		self.cells[row][col].elements = []
	}
	
	/// Applies the X-mark (blockage) rules to the grid after a suspect is placed.
	///
	/// - Parameters:
	///   - row: The row of the placement trigger.
	///   - col: The column of the placement trigger.
	/// - Note: All cells in the same row and column as the trigger are filled with X-marks, except the trigger cell itself.
	private func applyXMarkRules(forRow row: Int, col: Int) {
		let xMarkObject = MurdokuObject(name: "Bloqueo", element: .xMark)
		
		for r in 0..<rows {
			for c in 0..<columns {
				if r == row || c == col {
					guard r != row || c != col else { continue }
					cells[r][c].elements.append(xMarkObject)
				}
			}
		}
	}

	/// Sets the background color of a specific grid cell.
	///
	/// - Parameters:
	///   - newColor: The color to apply.
	///   - row: The row index.
	///   - col: The column index.
	private func setRoomColor(_ newColor: Color, atRow row: Int, col: Int) {
		guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
		cells[row][col].color = newColor
	}
	
	/// Starts the game timer if it is not already running.
	private func startTimer() {
		guard !isTimerRunning else { return }
		isTimerRunning = true
		timerStartDate = Date()
	}

	/// Pauses the game timer and persists the elapsed time.
	private func pauseTimer() {
		guard isTimerRunning else { return }
		elapsedTime += Date().timeIntervalSince(timerStartDate ?? Date())
		isTimerRunning = false
		timerStartDate = nil
	}

	/// Resets the game timer to zero.
	private func resetTimer() {
		elapsedTime = 0
		isTimerRunning = false
		timerStartDate = nil
	}

	/// The total elapsed time in seconds, including the current active session.
	var elapsedSeconds: TimeInterval {
		guard isTimerRunning, let timerStartDate else { return elapsedTime }
		return elapsedTime + Date().timeIntervalSince(timerStartDate)
	}

	/// Resets the game engine to its initial empty state and clears the timer.
	func resetGame() {
		self.rows = 0
		self.columns = 0
		self.suspects = []
		self.cells = []
		self.roomColors = []
		resetTimer()
	}
}
