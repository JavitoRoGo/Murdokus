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
				Text(object.element.rawValue.prefix(1).uppercased())
					.font(.caption2.bold())
					.foregroundColor(.white)
					.padding(4)
					.background(Color.black.opacity(0.5))
					.clipShape(Circle())
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
				if let object = try? decoder.decode(MurdokuObject.self, from: data) {
					engine.setElement(object, atRow: row, col: col)
				}
			}
		}
		return true
	}
	
	func validateDrop(info: DropInfo) -> DropProposal? {
		return DropProposal(operation: .move)
	}
}
