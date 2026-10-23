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
				row.append(Cell(element: nil, color: .secondary.opacity(0.2)))
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
	
    /// El punto único de entrada para cualquier modificación del tablero derivada de la UI.
    func handleIntent(_ intent: UserIntent) {
        switch intent {
        case .move(let package, let destRow, let destCol):
            performMove(package: package, toRow: destRow, col: destCol)
            
        case .delete(let package):
            performDelete(package: package)
        }
    }
	
    private func performMove(package: MurdokuTransferPackage, toRow: Int, col: Int) {
        guard toRow >= 0 && toRow < rows && col >= 0 && col < columns else { return }
        
        setElement(package.object, atRow: toRow, col: col)
        
        if package.sourceRow != toRow || package.sourceCol != col {
            clearCell(atRow: package.sourceRow, col: package.sourceCol)
        }
    }
	
    private func performDelete(package: MurdokuTransferPackage) {
        clearCell(atRow: package.sourceRow, col: package.sourceCol)
    }
	
	private func setElement(_ element: MurdokuObject?, atRow row: Int, col: Int) {
        guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
        cells[row][col].element = element
    }
	
	private func clearCell(atRow row: Int, col: Int) {
		guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
		self.cells[row][col].element = nil
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
