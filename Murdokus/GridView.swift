import SwiftUI

struct GridView: View {
    @Environment(GridEngine.self) private var engine
    @Environment(SavedGamesStore.self) private var savedGamesStore

    var body: some View {
		VStack(spacing: 5) {
			if let savedGameTitle {
				Text(savedGameTitle)
					.font(.largeTitle)
			}
			ScrollView([.horizontal, .vertical]) {
				if engine.rows == 0 || engine.columns == 0 {
					ContentUnavailableView("Tablero vacío", systemImage: "square.grid.3x3.fill", description: Text("Elige el número de filas y columnas."))
				} else {
					VStack(spacing: 16) {
						if engine.isSolved {
							Button("Guardar tiempo") {
								saveTime()
							}
							.buttonStyle(.bordered)
						}
						TimerView()
					}
					Divider()
					HStack(spacing: 20) {
						VStack(spacing: 0) {
							ForEach(0..<engine.rows, id: \.self) { row in
								HStack(spacing: 0) {
									ForEach(0..<engine.columns, id: \.self) { col in
										CellView(cell: engine.cells[row][col], row: row, col: col)
											.onTapGesture {
												applyColorToCell(row: row, col: col)
											}
									}
								}
							}
						}
						
						VStack(spacing: 5) {
							Button("Deshacer") {
								engine.handleIntent(.undo)
							}
							.buttonStyle(.bordered)
							.disabled(engine.isSolved || engine.undoStack.isEmpty)
							
							TrashView()
						}
					}
					.padding(20)
				}
			}
            .frame(minWidth: max(200, CGFloat(90 * engine.columns)))
        }
		.background(Color(NSColor.windowBackgroundColor))
    }

    private var savedGameTitle: String? {
        guard let savedGameID = engine.savedGameID else { return nil }
        return savedGamesStore.games.first(where: { $0.id == savedGameID })?.name
    }

    private func applyColorToCell(row: Int, col: Int) {
        if engine.selectedSuspect != nil {
            engine.handleIntent(.toggleSuspectCandidate(row: row, col: col))
            return
        }

        guard let activeColor = engine.activePaintColor else { return }

        engine.handleIntent(.changeColor(color: activeColor, row: row, col: col))
    }

    private func saveTime() {
        guard let savedGameID = engine.savedGameID,
              let game = savedGamesStore.games.first(where: { $0.id == savedGameID }) else { return }
        try? savedGamesStore.updateSolveTime(of: game, solveTime: engine.solvedTime ?? engine.elapsedTime)
    }
}

#Preview {
	GridView()
		.environment(GridEngine())
}
