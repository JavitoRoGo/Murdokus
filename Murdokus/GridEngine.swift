//
//  GridEngine.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

@Observable
final class GridEngine {
	var rows: Int = 0
	var columns: Int = 0
	var cells: [[Cell]] = []
	var suspects: [MurdokuObject] = []
	var draggingObject: MurdokuObject? = nil
	
	let objects: [MurdokuObject] = {
		MurdokuElement.elements.map {
			MurdokuObject(
				name: $0.rawValue,
				element: $0
			)
		}
	}()
	
	/// Define los tipos de acciones que un usuario puede intentar realizar en el tablero.
	enum UserIntent {
		case move(package: MurdokuTransferPackage, destinationRow: Int, destinationCol: Int)
		case delete(package: MurdokuTransferPackage)
	}
	
	func setupGameWith(rows: Int, columns: Int, suspectsNumber: Int) {
		self.rows = rows
		self.columns = columns
		generateGrid()
		generateSuspects(num: suspectsNumber)
	}
	
	private func generateGrid() {
		guard rows > 0 && columns > 0 else { return }
		var newCells: [[Cell]] = []
		
		for _ in 0..<rows {
			var row: [Cell] = []
			for _ in 0..<columns {
				row.append(Cell(elements: [], color: .secondary.opacity(0.2)))
			}
			newCells.append(row)
		}
		self.cells = newCells
	}
	
	private func generateSuspects(num: Int) {
		let names = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
		guard num > 0 && num <= names.count else { return }
		var suspectsList: [MurdokuObject] = []
		
		for i in 0 ..< num {
			let suspect = MurdokuObject(name: "Sospechoso \(names[i])", element: .suspect, capitalLetter: names[i])
			suspectsList.append(suspect)
		}
		self.suspects = suspectsList
	}
	
	func handleIntent(_ intent: UserIntent) {
		switch intent {
		case .move(let package, let destRow, let destCol):
			if canPlaceObject(atRow: destRow, col: destCol, newObject: package.object) {
				withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
					performMove(package: package, toRow: destRow, col: destCol)
				}
			}
			self.draggingObject = nil
		case .delete(let package):
			withAnimation(.spring()) {
				performDelete(package: package)
			}
			self.draggingObject = nil
		}
	}
	
	func canPlaceObject(atRow row: Int, col: Int, newObject: MurdokuObject) -> Bool {
		guard row >= 0 && row < rows && col >= 0 && col < columns else {
			return false
		}
		
		let targetCell = cells[row][col]
		
		if targetCell.elements.isEmpty {
			return true
		}
		
		if targetCell.elements.count >= 2 {
			return false
		}
		
		if let existingObject = targetCell.elements.last {
			if newObject.element == .suspect {
				return existingObject.element.canStackOnTop
			}
		}
		
		return false
	}
	
	private func performMove(package: MurdokuTransferPackage, toRow: Int, col: Int) {
		guard toRow >= 0 && toRow < rows && col >= 0 && col < columns else { return }
		if package.object.element == .suspect {
			applyXMarkRules(forRow: toRow, col: col)
		}
		cells[toRow][col].elements.append(package.object)
		
		if package.sourceRow != -1 && (package.sourceRow != toRow || package.sourceCol != col) {
			clearCellAt(row: package.sourceRow, col: package.sourceCol, objectToRemove: package.object)
		}
	}
	
	private func performDelete(package: MurdokuTransferPackage) {
		clearCellAt(row: package.sourceRow, col: package.sourceCol, objectToRemove: package.object)
	}
	
	private func clearCellAt(row: Int, col: Int, objectToRemove: MurdokuObject) {
		guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
		cells[row][col].elements.removeAll(where: { $0.id == objectToRemove.id })
	}
	
	private func clearCell(atRow row: Int, col: Int) {
		guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
		self.cells[row][col].elements = []
	}
	
	private func applyXMarkRules(forRow row: Int, col: Int) {
		let xMarkObject = MurdokuObject(name: "Bloqueo", element: .xMark)
		
		for r in 0..<rows {
			for c in 0..<columns {
				// No marcamos la celda donde está el sospechoso ni si es la misma posición.
				if r == row || c == col {
					guard r != row || c != col else { continue }
					cells[r][c].elements.append(xMarkObject)
				}
			}
		}
	}
	
	func setRoomColor(_ newColor: Color, atRow row: Int, col: Int) {
		guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
		cells[row][col].color = newColor
	}
	
	func resetGame() {
		self.rows = 0
		self.columns = 0
		self.suspects = []
		self.cells = []
	}
}
