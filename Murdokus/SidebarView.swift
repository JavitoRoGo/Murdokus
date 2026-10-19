import SwiftUI

struct SidebarView: View {
    var body: some View {
        List {
            Section("Configuración") {
                Text("Ajustes de cuadrícula próximamente...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.sidebar)
    }
}

#Preview {
    SidebarView()
		.environment(GridEngine(rows: 5, columns: 5, numOfSuspects: 2))
}
