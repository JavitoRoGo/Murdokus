//
//  ElementsView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

struct ElementsView: View {
	@Environment(GridEngine.self) private var engine
	@Environment(SavedGamesStore.self) private var savedGamesStore

	@State private var showingSaveSheet = false
	@State private var saveGameName = ""
	@State private var showingOverwriteAlert = false
	@State private var pendingSavedGame: SavedGame?

	var body: some View {
		let columns = [GridItem(.adaptive(minimum: 130))]
		
		ScrollView {
			if !engine.showingSuspects {
				Section {
					if engine.roomColors.isEmpty {
						ContentUnavailableView("Elige el número de espacios", systemImage: "paintbrush")
					} else {
						LazyVGrid(columns: columns) {
							ForEach(engine.roomColors, id: \.self) { color in
								RoomColorView(roomColor: color)
							}
						}
					}
				} header: {
					Text("Espacios")
						.font(.headline)
						.padding(.vertical, 10)
				}
				
				if !engine.roomColors.isEmpty {
					Divider()
					Section {
						LazyVGrid(columns: columns) {
							ForEach(engine.objects) { object in
								SingleElementView(object: object)
							}
						}
					} header: {
						Text("Elementos")
							.font(.headline)
					}
					
					Divider()
					
					VStack(spacing: 12) {
						Button("Guardar partida") {
							if let savedGameID = engine.savedGameID,
							   let game = savedGamesStore.games.first(where: { $0.id == savedGameID }) {
								saveGameName = game.name
							} else {
								saveGameName = ""
							}
							showingSaveSheet = true
						}
						.buttonStyle(.bordered)
						
						Button() {
							withAnimation {
								engine.activePaintColor = nil
								engine.handleTimer(.start)
								engine.showingSuspects = true
							}
						} label: {
							Text("Comenzar")
								.font(.largeTitle)
						}
						.buttonStyle(.borderedProminent)
					}
				}
			} else {
				Text("Pulsa sobre un sospechoso para marcar su ubicación posible.\nArrástralo para ponerlo en su ubicación definitiva.")
					.multilineTextAlignment(.center)
					.font(.subheadline)
				LazyVGrid(columns: columns) {
					ForEach(engine.suspects) { suspect in
						SingleElementView(object: suspect)
					}
				}
				Divider()
				HStack {
					SingleElementView(object: MurdokuObject(name: "Casilla bloqueada", element: .xMark))
					SingleElementView(object: MurdokuObject(name: "Víctima", element: .victim))
				}
			}
		}
		.frame(minWidth: 300)
		.padding()
		.background(Color(NSColor.windowBackgroundColor))
		.sheet(isPresented: $showingSaveSheet) {
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
						showingSaveSheet = false
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
	}
	
	/// Saves the current game configuration and board disposition under the given name.
	private func saveGame() {
		let trimmedName = saveGameName.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedName.isEmpty else { return }
		
		let snapshot = SavedGameSnapshot(
			rows: engine.rows,
			columns: engine.columns,
			colors: engine.roomColors.count,
			suspectsNumber: engine.suspects.count,
			cells: engine.cells.map { row in
				row.map { cell in
					SavedGameCell(elements: cell.elements, color: savedGameColor(from: cell.color))
				}
			}
		)
		
		let savedGame = SavedGame()
		savedGame.name = trimmedName
		savedGame.createdAt = Date()
		savedGame.rows = snapshot.rows
		savedGame.columns = snapshot.columns
		savedGame.colors = snapshot.colors
		savedGame.suspectsNumber = snapshot.suspectsNumber
		savedGame.solveTime = nil
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
		
		showingSaveSheet = false
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
		
		showingOverwriteAlert = false
		showingSaveSheet = false
		saveGameName = ""
	}
	
	/// Builds the color snapshot of a grid cell from its SwiftUI color.
	private func savedGameColor(from color: Color) -> SavedGameColor {
		let components = ColorHelper.decomposeColor(color)
		return SavedGameColor(red: components.red, green: components.green, blue: components.blue, opacity: components.opacity)
	}
}

#Preview {
    ElementsView()
		.environment(GridEngine())
		.environment(SavedGamesStore.preview)
}
