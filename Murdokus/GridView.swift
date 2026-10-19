import SwiftUI

struct GridView: View {
	@Environment(GridEngine.self) private var engine

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
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
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct CellView: View {
    let cell: Cell

    var body: some View {
        ZStack {
            // Fondo de la celda (la "habitación")
            cell.color
                .frame(width: 40, height: 40) // Tamaño fijo temporal para visualizar
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
		.environment(GridEngine(rows: 5, columns: 5, numOfSuspects: 3))
}
