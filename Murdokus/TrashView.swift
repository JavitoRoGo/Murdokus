import SwiftUI
import UniformTypeIdentifiers

struct TrashView: View {
    @Environment(GridEngine.self) private var engine

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Image(systemName: "trash")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    )
                
                Color.clear
                    .contentShape(Rectangle())
					.dropDestination(for: MurdokuTransferPackage.self) { incomingPackages, _ in
						guard let package = incomingPackages.first else { return false }
						engine.handleIntent(.delete(package: package))
						return true
					}
            }
			.frame(width: 80, height: 80)
			.onTapGesture {
				engine.activePaintColor = nil
			}
            
            Text("Arrastra aquí para borrar.\nToca para borrar la selección del color.")
                .font(.caption)
                .foregroundColor(.secondary)
				.multilineTextAlignment(.center)
                .padding(.bottom, 10)
        }
    }
}

#Preview {
	TrashView()
		.environment(GridEngine())
}
