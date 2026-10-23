import SwiftUI
import UniformTypeIdentifiers

struct TrashView: View {
    @Environment(GridEngine.self) private var engine

    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "trash")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    )
                
                Color.clear
                    .contentShape(Rectangle())
                    .onDrop(of: [UTType.murdokuObject], delegate: TrashDropDelegate(engine: engine))
            }
            
            Text("Arrastra aquí para borrar")
                .font(.caption)
                .foregroundColor(.secondary)
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
		
		itemProvider.loadDataRepresentation(forTypeIdentifier: MurdokuObjectProvider.typeIdentifier) { data, error in
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
