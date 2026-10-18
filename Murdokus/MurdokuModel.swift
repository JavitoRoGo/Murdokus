import SwiftUI

/// Representa los tipos de objetos que pueden existir en el tablero.
enum MurdokuElement: CaseIterable, Identifiable {
    case suspect
	case xMark
    case chair
    case table
    case rug
	case plant
	case bed
	case bookshelf

    var id: Self { self }

    /// Indica si este elemento permite que se coloque otro objeto encima (ej. una persona sobre una silla).
    var canStackOnTop: Bool {
        switch self {
		case .chair, .bed, .rug:
            return true
        default:
            return false
        }
    }
}

struct MurdokuObject {
	var name: String
	var element: MurdokuElement
}

/// Representa una única posición en la cuadrícula.
struct Cell {
    var element: MurdokuObject?
    /// El identificador de la habitación (determina el color de fondo).
    var color: Color
}

/// Motor central que gestiona el estado de la cuadrícula.
@Observable
final class GridEngine {
    var rows: Int
    var columns: Int
    var cells: [[Cell]] = []

    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.generateGrid(rows: rows, columns: columns)
    }

    /// Genera una nueva cuadrícula con las dimensiones especificadas.
    /// Por defecto, todas las celdas pertenecen a la habitación 0.
    func generateGrid(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        var newCells: [[Cell]] = []

        for _ in 0..<rows {
            var row: [Cell] = []
            for _ in 0..<columns {
				row.append(Cell(element: nil, color: .secondary))
            }
            newCells.append(row)
        }
        self.cells = newCells
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
