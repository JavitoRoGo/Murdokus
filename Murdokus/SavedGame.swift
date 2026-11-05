//
//  SavedGame.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 04/11/2026.
//

import Foundation
import SwiftData

/// A SwiftData model that represents a saved Murdoku game configuration.
@Model
final class SavedGame {
	/// The unique identifier of the saved game.
	var id: UUID = UUID()
	/// The name the user gave to the saved game.
	var name: String = ""
	/// The date when the saved game was created.
	var createdAt: Date = Date()
	/// The number of rows of the saved game board.
	var rows: Int = 0
	/// The number of columns of the saved game board.
	var columns: Int = 0
	/// The number of spaces or colors of the saved game board.
	var colors: Int = 0
	/// The number of suspects of the saved game.
	var suspectsNumber: Int = 0
	/// The time in seconds it took to solve the game, if it was solved.
	var solveTime: Double? = nil
	/// The encoded snapshot of the initial board disposition.
	var boardData: Data? = nil

	init() {
		id = UUID()
		name = ""
		createdAt = Date()
		rows = 0
		columns = 0
		colors = 0
		suspectsNumber = 0
		solveTime = nil
		boardData = nil
	}
}
