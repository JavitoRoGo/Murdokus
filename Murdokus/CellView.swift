//
//  CellView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 20/10/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct CellView: View {
	let cell: Cell
	let row: Int
	let col: Int
	@Environment(GridEngine.self) private var engine
	
	@State private var isTargeted: Bool = false
	@State private var isValidTarget: Bool = false

	var body: some View {
		ZStack {
			cell.color
				.frame(width: 80, height: 80)
                .overlay(hoverOverlay)
                .background(hoverBackground)
				.border(Color.black.opacity(0.1), width: 0.5)

            ForEach(cell.elements, id: \.id) { object in
                Image(systemName: object.element.icon(for: object.capitalLetter ?? ""))
                    .resizable()
                    .frame(width: 65, height: 65)
                    .foregroundColor(.black.opacity(0.7))
            }
		}
		.dropDestination(for: MurdokuTransferPackage.self) { incomingPackages, _ in
			guard let package = incomingPackages.first else { return false }
			engine.handleIntent(.move(package: package, destinationRow: row, destinationCol: col))
			return true
		} isTargeted: { targeted in
			if targeted {
				isTargeted = true
				let dummySuspect = MurdokuObject(name: "Check", element: .suspect)
				isValidTarget = engine.canPlaceObject(atRow: row, col: col, newObject: dummySuspect)
			} else {
				isTargeted = false
				isValidTarget = false
			}
		}
        .onDrag {
            if let topObject = cell.elements.last {
                NSItemProvider(object: MurdokuObjectProvider(object: topObject, row: row, col: col))
            } else {
				NSItemProvider()
            }
        } preview: {
            if let topObject = cell.elements.last {
                Image(systemName: topObject.element.icon(for: topObject.capitalLetter ?? ""))
                    .resizable()
                    .frame(width: 65, height: 65)
                    .foregroundColor(.black.opacity(0.7))
                    .padding(10)
                    .background(Circle().fill(.ultraThinMaterial))
            } else {
                Color.clear
            }
        }
	}
    
    @ViewBuilder
    private var hoverBackground: some View {
        if isTargeted {
			Color(isValidTarget ? .green : .red).opacity(0.2)
        } else {
            Color.clear
        }
    }
    
    @ViewBuilder
    private var hoverOverlay: some View {
        if isTargeted {
            Rectangle()
                .stroke(isValidTarget ? Color.green : Color.red, lineWidth: 3)
        } else {
            Color.clear
        }
    }
}

struct CellDropDelegate: DropDelegate {
	let row: Int
	let col: Int
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
					engine.handleIntent(.move(package: package, destinationRow: row, destinationCol: col))
				}
			}
		}
		return true
	}
	
	func validateDrop(info: DropInfo) -> DropProposal? {
		return DropProposal(operation: .move)
	}
}
