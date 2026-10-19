//
//  GridEngine.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

@Observable
final class GridEngine {
    var rows: Int
    var columns: Int
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

	init(rows: Int, columns: Int, numOfSuspects: Int) {
        self.rows = rows
        self.columns = columns
        self.generateGrid()
		self.generateSuspects(num: numOfSuspects)
    }

    /// Genera una nueva cuadrícula con las dimensiones especificadas.
    /// Por defecto, todas las celdas pertenecen a la habitación 0.
    private func generateGrid() {
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
		guard num > 0, num <= names.count else { return }
		var suspectsList: [MurdokuObject] = []
		
		for i in 0 ..< num {
			let suspect = MurdokuObject(name: "Sospechoso \(names[i])", element: .suspect, capitalLetter: names[i])
			suspectsList.append(suspect)
		}
		self.suspects = suspectsList
	}

    /// Actualiza el elemento en una posición específica.
    func setElement(_ element: MurdokuObject?, atRow row: Int, col: Int) {
        guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
        cells[row][col].element = element
    }

    /// Actualiza el roomID de una celda (útil para pintar las habitaciones).
	func setRoomID(_ newColor: Color, atRow row: Int, col: Int) {
        guard row >= 0 && row < rows && col >= 0 && col < columns else { return }
        cells[row][col].color = newColor
    }
}
