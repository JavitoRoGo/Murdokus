import SwiftUI

struct SidebarView: View {
	@State private var rows: Int = 3
	@State private var columns: Int = 3
	@State private var gridColors: Int = 1
	@State private var suspects: Int = 2
	@State private var isShowingSavedGames: Bool = false
	@Environment(GridEngine.self) private var engine
	@Environment(SavedGamesStore.self) private var savedGamesStore
	
    var body: some View {
        List {
            Section("Tablero") {
				Stepper(value: $rows, in: 1...9) {
					Text("Filas: \(rows)")
				}
				Stepper(value: $columns, in: 1...9) {
					Text("Columnas: \(columns)")
				}
            }
			
			Section("Espacios") {
				Stepper(value: $gridColors, in: 1...10) {
					Text("Espacios: \(gridColors)")
				}
			}
			
			Section("Sospechosos") {
				Stepper(value: $suspects, in: 1...8) {
					Text("Sospechosos: \(suspects)")
				}
            }
			
			Section {
				Button {
					isShowingSavedGames.toggle()
				} label: {
					Label("Mis partidas", systemImage: "archivebox")
				}
				
				if isShowingSavedGames {
					ForEach(savedGamesStore.games) { game in
						HStack(spacing: 8) {
							Button {
								load(game)
							} label: {
								VStack(alignment: .leading, spacing: 2) {
									Text(game.name)
										.font(.headline)
									if let solveTime = game.solveTime {
										Text("Resuelta en \(Self.formattedTime(solveTime))")
											.font(.subheadline)
											.foregroundStyle(.secondary)
									}
								}
							}
							.buttonStyle(.plain)
						}
						.swipeActions {
							Button("Borrar", role: .destructive) {
								try? savedGamesStore.delete(game)
							}
						}
					}
					
					Text("Pulsa sobre una línea para cargar el tablero.")
						.font(.caption2)
						.foregroundStyle(.secondary)
				}
			}
			
			Spacer()
			
			HStack(spacing: 10) {
				Button("Configurar") {
					engine.showingSuspects = false
					engine.handleTimer(.reset)
					engine.setupGameWith(rows: rows, columns: columns, suspectsNumber: suspects, colors: gridColors)
				}
				.buttonStyle(.bordered)
				Button("Borrar", role: .destructive) {
					engine.showingSuspects = false
					rows = 0
					columns = 0
					suspects = 0
					gridColors = 0
					engine.handleTimer(.reset)
					engine.resetGame()
				}
			}
        }
        .listStyle(.sidebar)
    }
	
	/// Loads the board disposition of the given saved game into the engine.
	private func load(_ game: SavedGame) {
		guard let data = game.boardData else { return }
		guard let snapshot = try? SavedGameSnapshot.decode(from: data) else { return }
		engine.loadSavedGame(snapshot, solveTime: game.solveTime)
		engine.savedGameID = game.id
	}

	/// Formats a solve time in seconds as a `mm:ss` string.
	private static func formattedTime(_ seconds: TimeInterval) -> String {
		let totalSeconds = Int(seconds.rounded())
		let minutes = totalSeconds / 60
		let seconds = totalSeconds % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
}

#Preview {
    SidebarView()
		.environment(GridEngine())
		.environment(SavedGamesStore.preview)
}
