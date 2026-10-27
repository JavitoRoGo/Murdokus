import SwiftUI

struct SidebarView: View {
	@State private var rows: Int = 3
	@State private var columns: Int = 3
	@State private var gridColors: Int = 1
	@State private var suspects: Int = 2
	@Environment(GridEngine.self) private var engine
	
    var body: some View {
        List {
            Section("Tablero") {
				Stepper(value: $rows, in: 0...20) {
					Text("Filas: \(rows)")
				}
				Stepper(value: $columns, in: 0...20) {
					Text("Columnas: \(columns)")
				}
            }
			
			Section("Espacios") {
				Stepper(value: $gridColors, in: 0...10) {
					Text("Espacios: \(gridColors)")
				}
			}
			
			Section("Sospechosos") {
				Stepper(value: $suspects, in: 0...26) {
					Text("Sospechosos: \(suspects)")
				}
            }
			
			Spacer()
			
			HStack(spacing: 10) {
				Button("Configurar") {
					engine.showingSuspects = false
					engine.setupGameWith(rows: rows, columns: columns, suspectsNumber: suspects, colors: gridColors)
				}
				.buttonStyle(.bordered)
				Button("Borrar", role: .destructive) {
					engine.showingSuspects = false
					rows = 0
					columns = 0
					suspects = 0
					gridColors = 0
					engine.resetGame()
				}
			}
        }
        .listStyle(.sidebar)
    }
}

#Preview {
    SidebarView()
		.environment(GridEngine())
}
