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
                    .onDrop(of: [UTType.murdokuObject], delegate: TrashDropDelegate(engine: engine))
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

struct TrashDropDelegate: DropDelegate {
	let engine: GridEngine
	
	func performDrop(info: DropInfo) -> Bool {
		guard let itemProvider = info.itemProviders(for: [UTType.murdokuObject]).first else {
			return false
		}
		
		itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.murdokuObject.identifier) { data, error in
			guard let data = data, error == nil else { return }
			
			Task { @MainActor in
				let decoder = JSONDecoder()
				if let package = try? decoder.decode(MurdokuTransferPackage.self, from: data) {
					engine.handleIntent(.delete(package: package))
				}
			}
		}
		return true
	}
	
	func validateDrop(info: DropInfo) -> DropProposal? {
		return DropProposal(operation: .move)
	}
}
