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
	var games: [SavedGame] = []

	/// The model context used to persist the saved games.
	private let modelContext: ModelContext

	/// Initializes a new store with the given model context.
	init(modelContext: ModelContext) {
		self.modelContext = modelContext
		loadGames()
	}

	/// Reloads the list of saved games from the model context.
	private func loadGames() {
		games = (try? modelContext.fetch(FetchDescriptor<SavedGame>())) ?? []
	}

	/// Saves the given game, updating the existing record that matches the same configuration when found.
	///
	/// - Parameter game: The game to persist.
	/// - Returns: The persisted game.
	@discardableResult
	func save(_ game: SavedGame) throws -> SavedGame {
		let games = (try? modelContext.fetch(FetchDescriptor<SavedGame>())) ?? []
		let existing = games.first {
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
		
		defer { loadGames() }

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

	/// Returns the saved game that uses the given name, if any.
	func savedGame(named name: String) -> SavedGame? {
		games.first { $0.name.lowercased() == name.lowercased() }
	}

	/// Overwrites the saved game that uses the given name with the data of the provided game.
	func overwrite(named name: String, with game: SavedGame) throws {
		guard let existing = savedGame(named: name) else { return }
		existing.name = game.name
		existing.createdAt = game.createdAt
		existing.solveTime = game.solveTime
		existing.rows = game.rows
		existing.columns = game.columns
		existing.colors = game.colors
		existing.suspectsNumber = game.suspectsNumber
		existing.boardData = game.boardData
		try modelContext.save()
	}

	/// Updates the solve time of the given saved game.
	func updateSolveTime(of game: SavedGame, solveTime: Double) throws {
		game.solveTime = solveTime
		try modelContext.save()
		loadGames()
	}
	
	/// Deletes the given saved game.
	func delete(_ game: SavedGame) throws {
		modelContext.delete(game)
		try modelContext.save()
		loadGames()
	}
}

extension SavedGamesStore {
	/// A preview instance of `SavedGamesStore` using an in-memory `ModelContainer`.
	static var preview: SavedGamesStore {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try! ModelContainer(for: SavedGame.self, configurations: config)
		let context = ModelContext(container)
		return SavedGamesStore(modelContext: context)
	}
}
