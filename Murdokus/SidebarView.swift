import SwiftUI

struct SidebarView: View {
	@State private var rows: Int = 0
	@State private var columns: Int = 0
	@State private var suspects: Int = 0
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
			
			Section("Sospechosos") {
				Stepper(value: $suspects, in: 0...26) {
					Text("Sospechosos: \(suspects)")
				}
            }
			
			Spacer()
			
			HStack(spacing: 10) {
				Button("Empezar") {
					engine.setupGameWith(rows: rows, columns: columns, suspectsNumber: suspects)
				}
				.buttonStyle(.bordered)
				Button("Borrar", role: .destructive) {
					rows = 0
					columns = 0
					suspects = 0
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
