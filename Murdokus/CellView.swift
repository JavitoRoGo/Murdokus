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

			if let object = cell.element {
				Image(systemName: object.element.icon(for: object.capitalLetter ?? ""))
					.resizable()
					.frame(width: 75, height: 75)
					.foregroundColor(.black.opacity(0.5))
					.onDrag {
						NSItemProvider(object: MurdokuObjectProvider(object: object, row: row, col: col))
					} preview: {
						Image(systemName: object.element.icon(for: object.capitalLetter ?? ""))
							.resizable()
							.frame(width: 75, height: 75)
							.foregroundColor(.black.opacity(0.5))
							.padding(10)
							.background(Circle().fill(.ultraThinMaterial))
					}
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
