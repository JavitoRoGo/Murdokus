//
//  SavedGamesStoreTests.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 05/11/2026.
//

import Testing
import SwiftData
import Foundation
@testable import Murdokus

@Suite("Pruebas de Persistencia de Partidas Guardadas (SavedGamesStore)")
struct SavedGamesStoreTests {
	private let store: SavedGamesStore

	init() {
		let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
		let modelContainer = try! ModelContainer(for: SavedGame.self, configurations: modelConfiguration)
		let modelContext = ModelContext(modelContainer)
		store = SavedGamesStore(modelContext: modelContext)
	}

	@Test("La lista de partidas guardadas debe estar vacía al crear la store")
	func initialGamesAreEmpty() {
		#expect(store.games.isEmpty)
	}

	@Test("Guardar una partida nueva debe persistirla")
	func savePersistsNewGame() throws {
		let game = SavedGame()
		game.name = "Partida 1"
		game.rows = 2
		game.columns = 2
		game.colors = 1
		game.suspectsNumber = 2
		game.solveTime = nil
		game.boardData = try? SavedGameSnapshot.encode(SavedGameSnapshot(rows: 2, columns: 2, colors: 1, suspectsNumber: 2, cells: [[SavedGameCell(color: SavedGameColor(red: 0.5, green: 0.5, blue: 0.5, opacity: 1))]]))

		_ = try store.save(game)

		#expect(store.games.count == 1)
		let persisted = try #require(store.games.first)
		#expect(persisted.name == "Partida 1")
		#expect(persisted.rows == 2)
		#expect(persisted.columns == 2)
		#expect(persisted.colors == 1)
		#expect(persisted.suspectsNumber == 2)
		#expect(persisted.boardData != nil)
	}

	@Test("Guardar una partida con la misma configuración debe actualizar el registro existente")
	func saveUpdatesExistingGame() throws {
		let game = SavedGame()
		game.name = "Partida 1"
		game.rows = 2
		game.columns = 2
		game.colors = 1
		game.suspectsNumber = 2
		game.boardData = try? SavedGameSnapshot.encode(SavedGameSnapshot(rows: 2, columns: 2, colors: 1, suspectsNumber: 2, cells: [[SavedGameCell(color: SavedGameColor(red: 0.5, green: 0.5, blue: 0.5, opacity: 1))]]))

		_ = try store.save(game)

		let gameToUpdate = SavedGame()
		gameToUpdate.name = "Partida 1"
		gameToUpdate.rows = 2
		gameToUpdate.columns = 2
		gameToUpdate.colors = 1
		gameToUpdate.suspectsNumber = 2
		gameToUpdate.boardData = game.boardData

		_ = try store.save(gameToUpdate)
		#expect(store.games.count == 1)
		#expect(store.games.first?.name == "Partida 1")
	}

	@Test("Actualizar el tiempo de resolución debe persistir el dato")
	func updateSolveTimePersistsTime() throws {
		let game = SavedGame()
		game.name = "Partida 1"
		game.rows = 2
		game.columns = 2
		game.colors = 1
		game.suspectsNumber = 2
		game.solveTime = nil
		_ = try store.save(game)

		let persisted = try #require(store.games.first)
		try store.updateSolveTime(of: persisted, solveTime: 125.5)

		let updated = try #require(store.games.first)
		#expect(updated.solveTime == 125.5)
	}

	@Test("Borrar una partida debe eliminar el registro")
	func deleteRemovesGame() throws {
		let game = SavedGame()
		game.name = "Partida 1"
		game.rows = 2
		game.columns = 2
		game.colors = 1
		game.suspectsNumber = 2
		_ = try store.save(game)

		let persisted = try #require(store.games.first)
		try store.delete(persisted)

		#expect(store.games.isEmpty)
	}

	@Test("El snapshot de partida debe sobrevivir al guardar y recargar sin pérdida de datos")
	func snapshotSurvivesPersistenceRoundTrip() throws {
		let cell = SavedGameCell(
			elements: [MurdokuObject(name: "Silla", element: .chair)],
			color: SavedGameColor(red: 0.2, green: 0.4, blue: 0.6, opacity: 0.7)
		)
		let snapshot = SavedGameSnapshot(rows: 2, columns: 2, colors: 1, suspectsNumber: 1, cells: [[cell, cell], [cell, cell]])

		let game = SavedGame()
		game.name = "Partida 1"
		game.boardData = try SavedGameSnapshot.encode(snapshot)
		_ = try store.save(game)

		let persisted = try #require(store.games.first)
		let data = try #require(persisted.boardData)
		let decoded = try SavedGameSnapshot.decode(from: data)

		#expect(decoded.rows == 2)
		#expect(decoded.columns == 2)
		#expect(decoded.colors == 1)
		#expect(decoded.suspectsNumber == 1)
		#expect(decoded.cells.count == 2)
		#expect(decoded.cells[0][0].elements.count == 1)
		#expect(decoded.cells[0][0].elements.first?.name == "Silla")
		#expect(decoded.cells[0][0].color.red == 0.2)
		#expect(decoded.cells[0][0].color.green == 0.4)
		#expect(decoded.cells[0][0].color.blue == 0.6)
		#expect(decoded.cells[0][0].color.opacity == 0.7)
	}

	@Test("Cargar una partida guardada debe restaurar el estado del motor")
	func savedGameRestoresEngineState() throws {
		let engine = GridEngine()
		engine.setupGameWith(rows: 2, columns: 2, suspectsNumber: 1, colors: 1)
		engine.handleIntent(.move(package: MurdokuTransferPackage(object: MurdokuObject(name: "Silla", element: .chair), sourceRow: -1, sourceCol: -1), destinationRow: 1, destinationCol: 1))

		let snapshot = SavedGameSnapshot(
			rows: engine.rows,
			columns: engine.columns,
			colors: engine.roomColors.count,
			suspectsNumber: engine.suspects.count,
			cells: engine.cells.map { row in
				row.map { cell in
					let components = ColorHelper.decomposeColor(cell.color)
					return SavedGameCell(
						elements: cell.elements,
						color: SavedGameColor(red: components.red, green: components.green, blue: components.blue, opacity: components.opacity)
					)
				}
			}
		)

		let savedGame = SavedGame()
		savedGame.name = "Partida 1"
		savedGame.boardData = try SavedGameSnapshot.encode(snapshot)
		_ = try store.save(savedGame)

		let persisted = try #require(store.games.first)
		let data = try #require(persisted.boardData)
		let decoded = try SavedGameSnapshot.decode(from: data)

		engine.loadSavedGame(decoded, solveTime: nil)

		#expect(engine.rows == 2)
		#expect(engine.columns == 2)
		#expect(engine.cells[1][1].elements.count == 1)
		#expect(engine.cells[1][1].elements.first?.name == "Silla")
	}

	@Test("Cargar una partida resuelta guardada debe restaurar el estado final y el tiempo de resolución")
	func savedSolvedGameRestoresEngineState() throws {
		let engine = GridEngine()
		engine.setupGameWith(rows: 2, columns: 2, suspectsNumber: 1, colors: 1)
		engine.handleTimer(.start)

		let victim = MurdokuObject(name: "Víctima", element: .victim)
		engine.handleIntent(.move(package: MurdokuTransferPackage(object: victim, sourceRow: -1, sourceCol: -1), destinationRow: 1, destinationCol: 1))

		#expect(engine.isSolved == true)
		let solveTime = engine.solvedTime
		let snapshot = engine.boardSnapshot()

		let savedGame = SavedGame()
		savedGame.name = "Partida 1"
		savedGame.boardData = try SavedGameSnapshot.encode(snapshot)
		savedGame.solveTime = solveTime
		_ = try store.save(savedGame)

		let persisted = try #require(store.games.first)
		let data = try #require(persisted.boardData)
		let decoded = try SavedGameSnapshot.decode(from: data)

		engine.loadSavedGame(decoded, solveTime: persisted.solveTime)

		#expect(engine.solvedTime == persisted.solveTime)
		#expect(engine.cells[1][1].elements.count == 1)
		#expect(engine.cells[1][1].elements.first?.element == .victim)
	}
}
