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

	var body: some View {
		ZStack {
			cell.color
				.frame(width: 80, height: 80)
				.border(Color.black.opacity(0.1), width: 0.5)

            ForEach(cell.elements, id: \.id) { object in
                Image(systemName: object.element.icon(for: object.capitalLetter ?? ""))
                    .resizable()
                    .frame(width: 65, height: 65) // Reducimos ligeramente para que se note el apilamiento
                    .foregroundColor(.black.opacity(0.7))
            }
		}
        // El drag se gestiona desde la celda misma o de un objeto específico. 
        // Para mantener la simplicidad y permitir mover "el objeto de arriba":
        .onDrag {
            if let topObject = cell.elements.last {
                NSItemProvider(object: MurdokuObjectProvider(object: topObject, row: row, col: col))
            } else {
                // Si no hay nada para arrastrar, devolvemos un provider vacío o manejamos el error
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
		.onDrop(of: [UTType.murdokuObject], delegate: CellDropDelegate(row: row, col: col, engine: engine))
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
