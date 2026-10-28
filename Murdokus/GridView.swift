import SwiftUI

struct GridView: View {
    @Environment(GridEngine.self) private var engine

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            if engine.rows == 0 || engine.columns == 0 {
                ContentUnavailableView("Tablero vacío", systemImage: "square.grid.3x3.fill", description: Text("Elige el número de filas y columnas."))
			} else {
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
					
					TrashView()
				}
			}
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(minWidth: max(200, CGFloat(90 * engine.columns)))
    }

    private func applyColorToCell(row: Int, col: Int) {
        guard let activeColor = engine.activePaintColor else { return }
        
        engine.handleIntent(.changeColor(color: activeColor, row: row, col: col))
    }
}

#Preview {
	GridView()
		.environment(GridEngine())
}
