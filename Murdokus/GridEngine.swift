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
    
    /// Determina si se puede colocar un nuevo objeto en una celda específica basándose en las reglas de apilamiento y límite de 2.
    private func canPlaceObject(atRow row: Int, col: Int, newObject: MurdokuObject) -> Bool {
        guard row >= 0 && row < rows && col >= 0 && col < columns else {
            return false
        }
        
        let targetCell = cells[row][col]
        
        // Si la celda está vacía, siempre podemos ponerlo.
        if targetCell.elements.isEmpty {
            return true
        }
        
        // Si ya tiene 2 objetos, el límite ha sido alcanzado.
        if targetCell.elements.count >= 2 {
            return false
        }
        
        // Si tiene 1 objeto, comprobamos si el existente permite apilar algo encima.
        if let existingObject = targetCell.elements.last {
            return existingObject.element.canStackOnTop
        }
        
        return false
    }

    /// El punto único de entrada para cualquier modificación del tablero derivada de la UI.
    func handleIntent(_ intent: UserIntent) {
        switch intent {
        case .move(let package, let destRow, let destCol):
            if canPlaceObject(atRow: destRow, col: destCol, newObject: package.object) {
                performMove(package: package, toRow: destRow, col: destCol)
            } else {
                print("Movimiento no permitido: Límite de apilamiento alcanzado o base incompatible.")
            }
            
        case .delete(let package):
            performDelete(package: package)
        }
    }
    
    private func performMove(package: MurdokuTransferPackage, toRow: Int, col: Int) {
        guard toRow >= 0 && toRow < rows && col >= 0 && col < columns else { return }
        
        // Añadimos el objeto a la pila de la celda de destino
        cells[toRow][col].elements.append(package.object)
        
        // Si el objeto no venía de una celda existente (es nuevo), o si viene de otra, limpiamos la origen
        if package.sourceRow != -1 && (package.sourceRow != toRow || package.sourceCol != col) {
            clearCellAt(row: package.sourceRow, col: package.sourceCol, objectToRemove: package.object)
        }
    }
    
    private func performDelete(package: MurdokuTransferPackage) {
        clearCellAt(row: package.sourceRow, col: package.sourceCol, objectToRemove: package.object)
    }

    /// Elimina un objeto específico de una celda (útil para movimientos entre celdas).
    private func clearCellAt(row: Int, col: Int, objectToRemove: MurdokuObject) {
        guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
        // Eliminamos el objeto de la lista de elementos de esa celda
        cells[row][col].elements.removeAll(where: { $0.id == objectToRemove.id })
    }
	
//	private func setElement(_ element: MurdokuObject?, atRow row: Int, col: Int) {
//        guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
//        cells[row][col].elements = element != nil ? [element!] : []
//    }
	
	private func clearCell(atRow row: Int, col: Int) {
		guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
		self.cells[row][col].elements = []
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
