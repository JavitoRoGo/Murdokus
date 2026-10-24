import SwiftUI

struct GridView: View {
	@Environment(GridEngine.self) private var engine

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(spacing: 0) {
                ForEach(0..<engine.rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<engine.columns, id: \.self) { col in
							CellView(cell: engine.cells[row][col], row: row, col: col)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
	GridView()
		.environment(GridEngine())
}
