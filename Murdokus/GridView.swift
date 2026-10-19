import SwiftUI

struct GridView: View {
	@Environment(GridEngine.self) private var engine

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
			if engine.rows == 0 || engine.columns == 0 {
				ContentUnavailableView("Tablero vacío", systemImage: "square.grid.3x3.fill", description: Text("Elige el número de filas y columnas."))
			} else {
            	VStack(spacing: 0) {
					ForEach(0..<engine.rows, id: \.self) { row in
						HStack(spacing: 0) {
							ForEach(0..<engine.columns, id: \.self) { col in
								CellView(cell: engine.cells[row][col])
							}
						}
					}
				}
				.padding(20)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
		.frame(minWidth: CGFloat(90 * engine.columns))
    }
}

struct CellView: View {
    let cell: Cell

    var body: some View {
        ZStack {
            cell.color
                .frame(width: 80, height: 80)
                .border(Color.black.opacity(0.1), width: 0.5)

            // Representación del elemento si existe
            if let object = cell.element {
                Text(object.element.rawValue.prefix(1).uppercased())
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    GridView()
		.environment(GridEngine())
}
