import SwiftUI

/// Representa los tipos de objetos que pueden existir en el tablero.
enum MurdokuElement: String, CaseIterable, Identifiable {
    case suspect = "Sospechoso"
	case xMark = "X"
    case chair = "Silla"
    case table = "Mesa"
    case rug = "Alfombra"
	case plant = "Planta"
	case bed = "Cama"
	case bookshelf = "Estantería"
	case tv = "TV"

    var id: Self { self }
	
	func icon(for suspect: String = "") -> String {
		switch self {
		case .suspect: "\(suspect.lowercased()).circle.fill"
		case .xMark: "xmark"
		case .chair: "chair.lounge"
		case .table: "table.furniture"
		case .rug: "light.panel"
		case .plant: "camera.macro"
		case .bed: "bed.double.fill"
		case .bookshelf: "books.vertical"
		case .tv: "tv"
		}
	}

    /// Indica si este elemento permite que se coloque otro objeto encima (ej. una persona sobre una silla).
    var canStackOnTop: Bool {
        switch self {
		case .chair, .bed, .rug:
            return true
        default:
            return false
        }
    }
	
	static var elements: [MurdokuElement] {
		self.allCases.filter { $0 != .suspect }
	}
}

struct MurdokuObject: Identifiable {
	var id: String { name }
	var name: String
	var element: MurdokuElement
	var capitalLetter: String? = nil
}

/// Representa una única posición en la cuadrícula.
struct Cell {
    var element: MurdokuObject?
    /// El identificador de la habitación (determina el color de fondo).
    var color: Color
}


