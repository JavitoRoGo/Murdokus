//
//  SaveGameSheet.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 10/11/2026.
//

import SwiftUI

/// A sheet that allows the user to give a name to a game and persist it, optionally associating a solve time.
///
/// The sheet is reused by the save and save-time flows of the game, so a solved game
/// that has not been saved yet can be named and stored with its solve time.
struct SaveGameSheet: View {
	@Environment(GridEngine.self) private var engine
	@Environment(SavedGamesStore.self) private var savedGamesStore
	@Environment(\.dismiss) private var dismiss

	/// The name of the game, bound from the presenting view.
	@Binding var saveGameName: String
	/// The solve time to persist with the game, if any.
	var solveTime: TimeInterval?

	@State private var showingOverwriteAlert = false
	@State private var pendingSavedGame: SavedGame?

	/// Initializes the sheet with the given game name binding and optional solve time.
	init(saveGameName: Binding<String>, solveTime: TimeInterval? = nil) {
		self._saveGameName = saveGameName
		self.solveTime = solveTime
	}

	var body: some View {
		VStack(spacing: 16) {
			Text("Ponle un nombre a tu partida para poder identificarla después.")
				.font(.headline)
				.multilineTextAlignment(.center)

			TextField("Nombre de la partida", text: $saveGameName)
				.textFieldStyle(.roundedBorder)
				.onSubmit {
					saveGame()
				}

			HStack(spacing: 10) {
				Button("Cancelar") {
					dismiss()
				}
				Button("Guardar") {
					saveGame()
				}
				.disabled(saveGameName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
			}
		}
		.padding(20)
		.frame(minWidth: 320)
		.background(Color(NSColor.windowBackgroundColor))
		.alert("El nombre ya existe", isPresented: $showingOverwriteAlert) {
			Button("Sí, sobrescribir") {
				saveOverwrite()
			}
			Button("No", role: .cancel) {}
		} message: {
			Text("Ya existe una partida guardada con el nombre \"\(pendingSavedGame?.name ?? saveGameName)\". ¿Quieres sobrescribirla con los datos actuales?")
		}
	}

	/// Saves the current game board disposition under the given name, associating the solve time when provided.
	private func saveGame() {
		let trimmedName = saveGameName.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedName.isEmpty else { return }

		let snapshot = engine.boardSnapshot()

		let savedGame = SavedGame()
		savedGame.name = trimmedName
		savedGame.createdAt = Date()
		savedGame.rows = snapshot.rows
		savedGame.columns = snapshot.columns
		savedGame.colors = snapshot.colors
		savedGame.suspectsNumber = snapshot.suspectsNumber
		savedGame.solveTime = solveTime
		savedGame.boardData = try? SavedGameSnapshot.encode(snapshot)

		if savedGamesStore.savedGame(named: trimmedName) != nil {
			pendingSavedGame = savedGame
			showingOverwriteAlert = true
			return
		}

		do {
			let saved = try savedGamesStore.save(savedGame)
			engine.savedGameID = saved.id
		} catch {
			return
		}

		dismiss()
		saveGameName = ""
	}

	/// Overwrites the saved game that uses the given name with the data of the provided game.
	private func saveOverwrite() {
		guard let savedGame = pendingSavedGame else { return }

		do {
			try savedGamesStore.overwrite(named: savedGame.name, with: savedGame)
			if let existing = savedGamesStore.savedGame(named: savedGame.name) {
				engine.savedGameID = existing.id
			}
		} catch {
			return
		}

		dismiss()
		saveGameName = ""
	}
}

#Preview {
	SaveGameSheet(saveGameName: .constant(""))
}
