//
//  SavedGamesStore.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 05/11/2026.
//

import Foundation
import SwiftData

/// An observable store that manages the saved games persisted with SwiftData.
@Observable
final class SavedGamesStore {
	/// The list of saved games of the app.
	private(set) var savedGames: [SavedGame] = []

	/// The model context used to persist the saved games.
	private let modelContext: ModelContext

	/// Initializes a new store with the given model context.
	init(modelContext: ModelContext) {
		self.modelContext = modelContext
	}

	/// Initializes a new store with a model container that holds the saved games.
	init() {
		let schema = Schema([SavedGame.self])
		let modelConfiguration = ModelConfiguration(schema: schema)
		do {
			let modelContainer = try ModelContainer(for: SavedGame.self, configurations: modelConfiguration)
			modelContext = ModelContext(modelContainer)
		} catch {
			fatalError("Failed to create the ModelContainer for the saved games.")
		}
	}

	/// The list of saved games available for playing.
	var games: [SavedGame] { savedGames }

	/// Reloads the list of saved games from the model context.
	func load() {
		savedGames = (try? modelContext.fetch(FetchDescriptor<SavedGame>())) ?? []
	}

	/// Saves the given game, updating the existing record that matches the same configuration when found.
	///
	/// - Parameter game: The game to persist.
	/// - Returns: The persisted game.
	@discardableResult
	func save(_ game: SavedGame) throws -> SavedGame {
		let existing = savedGames.first {
			$0.rows == game.rows &&
			$0.columns == game.columns &&
			$0.colors == game.colors &&
			$0.suspectsNumber == game.suspectsNumber &&
			$0.boardData == game.boardData
		}

		if let existing {
			existing.name = game.name
			existing.createdAt = game.createdAt
			existing.solveTime = game.solveTime
			existing.boardData = game.boardData
			try modelContext.save()
			return existing
		}

		let newGame = SavedGame()
		newGame.name = game.name
		newGame.createdAt = game.createdAt
		newGame.rows = game.rows
		newGame.columns = game.columns
		newGame.colors = game.colors
		newGame.suspectsNumber = game.suspectsNumber
		newGame.solveTime = game.solveTime
		newGame.boardData = game.boardData
		modelContext.insert(newGame)
		try modelContext.save()
		return newGame
	}

	/// Updates the solve time of the given saved game.
	func updateSolveTime(of game: SavedGame, solveTime: Double) throws {
		game.solveTime = solveTime
		try modelContext.save()
	}

	/// Updates the name of the given saved game.
	func updateName(of game: SavedGame, name: String) throws {
		game.name = name
		try modelContext.save()
	}

	/// Deletes the given saved game.
	func delete(_ game: SavedGame) throws {
		modelContext.delete(game)
		try modelContext.save()
	}
}
